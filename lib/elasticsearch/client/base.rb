require 'logger'
require 'rest-client'
require 'elasticsearch/manager/errors'

module Elasticsearch
  module Client
    class Base
      def initialize(host = 'localhost', port = 9200, logger = Logger.new(STDOUT))
        @host = host
        @port = port
        @logger = logger
      end

      def get(uri, params = nil)
        raw = _get(uri, params)
        if !raw.headers[:content_type].nil? && raw.headers[:content_type][/json/]
          JSON.parse(raw)
        else
          raw
        end
      end

      def put(uri, body, params = nil)
        raw = _put(uri, body, params)
        if !raw.headers[:content_type].nil? && raw.headers[:content_type][/json/]
          JSON.parse(raw)
        else
          raw
        end
      end

      def _get(uri, params = nil)
        url = _build_url(uri)
        opts = _prep_opts(params)

        begin
          return RestClient.get url, opts
        rescue Exception => e
          raise Elasticsearch::Manager::ApiError.new "Unable to complete get request: #{e}"
        end
      end

      def _put(uri, body, params = nil)
        url = _build_url(uri)
        opts = _prep_opts(params)

        begin
          return RestClient.put url, body, opts
        rescue Exception => e
          raise Elasticsearch::Manager::ApiError.new "Unable to complete put request: #{e}"
        end
      end

      def _prep_opts(params)
        unless params.nil?
                 {:params => params}
               else
                 {}
               end
      end

      protected

      def _build_url(uri)
        "http://#{@host}:#{@port}#{uri}"
      end
    end
  end
end
