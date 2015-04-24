require 'ostruct'
require 'representable/json'

module Elasticsearch
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
    end
    extend Representer
  end
end
