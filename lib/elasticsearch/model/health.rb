require 'ostruct'
require 'representable/json'

module Elasticsearch
  module Model
    class Health < OpenStruct
      module Representer
        include Representable::JSON
        include Representable::Hash
        include Representable::Hash::AllowSymbols
  
        property :cluster_name
        property :status
        property :timed_out
        property :number_of_nodes
        property :number_of_data_nodes
        property :active_primary_shards
        property :active_shards
        property :relocating_shards
        property :initializing_shards
        property :unassigned_shards
      end
      extend Representer
    end
  end
end
