require 'ostruct'
require 'representable/json'

module Elasticsearch
  module Model
    class RoutingNodes < OpenStruct
      module Representer
        include Representable::JSON
        include Representable::Hash
        include Representable::Hash::AllowSymbols
  
        property :cluster_name
        property :master_node
        nested :routing_nodes do
          property :unassigned, setter: (lambda do |v,args|
            self.unassigned = v.map {|s| Elasticsearch::Model::Shard.new.extend(Elastiman::Model::Shard::Representer).from_hash(s) }
          end)
          property :nodes, setter: (lambda do |v,args|
            self.nodes = v.map do |id, shards|
              shards.each { |shard| Elasticsearch::Model::Shard.new.extend(Elastiman::Model::Shard::Representer).from_hash(shard) }
            end.flatten
          end)
        end
      end
      extend Representer
    end
  end
end
