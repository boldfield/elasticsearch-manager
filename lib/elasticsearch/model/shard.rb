require 'ostruct'
require 'representable/json'

module Elasticsearch
  module Model
    class Shard < OpenStruct
      module Representer
        include Representable::JSON
        include Representable::Hash
        include Representable::Hash::AllowSymbols
  
        property :state
        property :primary
        property :node
        property :realocating_node
        property :shard
        property :index
      end
      extend Representer
    end
  end
end
