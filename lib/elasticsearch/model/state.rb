require 'ostruct'
require 'representable/json'

module Elasticsearch
  module Model
    class ClusterState < OpenStruct
      module Representer
        include Representable::JSON
        include Representable::Hash
        include Representable::Hash::AllowSymbols

        property :cluster_name
        property :master_node
        property :nodes, setter: (lambda do |v,args|
          self.nodes = v.map do |id,node|
            n = Elasticsearch::Model::Node.new.extend(Elasticsearch::Model::Node::Representer).from_hash(node)
            n.id, n.master, n.ip = id, id == self.master_node, n.transport_address[/\d+\.\d+\.\d+\.\d+/]
            n
          end
        end)
        property :routing_nodes, setter: (lambda do |v,args|
          v.each do |status,routes|
            if status == 'nodes'
              routes.each do |id,shards|
                n = self.nodes.select { |n| n.id == id }[0]
                s = shards.map do |shard|
                  Elasticsearch::Model::Shard.new.extend(Elasticsearch::Model::Shard::Representer).from_hash(shard)
                end
                n.shards = s
              end
            elsif status == 'unassigned'
              self.unassigned_shards = routes.map do |shard|
                Elasticsearch::Model::Shard.new.extend(Elasticsearch::Model::Shard::Representer).from_hash(shard)
              end
            end
          end
        end)
      end

      def count_unassigned_shards
        unassigned_shards.length
      end
      extend Representer
    end
  end
end
