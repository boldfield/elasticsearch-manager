require 'ostruct'
require 'representable/json'

module Elasticsearch
  module Model
    class Node < OpenStruct
      module Representer
        include Representable::JSON
        include Representable::Hash
        include Representable::Hash::AllowSymbols
  
        property :name
        property :transport_address
        property :host
        property :ip
        property :version
        property :build
        property :http_address
  
        nested :settings do
          nested :gateway do
            property :gateway_expected_nodes, as: :expected_nodes
          end
  
          nested :http do
            property :http_port, as: :port
          end
  
          nested :path do
            property :data_path, as: :data
            property :home_path, as: :home
            property :logs_path, as: :logs
            property :conf_path, as: :conf
          end
        end
      end
      extend Representer
    end
  end
end
