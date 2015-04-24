require 'json'


module Elasticsearch
  module Client
    class ESClient < Base
      def status
        data = get('/_cluster/health')
        data['status']
      end

      def green?
        status == 'green'
      end

      def health
        get('/_cluster/health')
      end

      def nodes
        get('/_nodes')
      end

      def state
        get('/_cluster/state')
      end

      def settings
        get('/_cluster/settings')
      end

      def routing(disable = true)
        data = {
          'transient' => {
            'cluster.routing.allocation.enable' => disable ? 'none' : 'all'
          }
        }.to_json

        put('/_cluster/settings', data)
      end
    end
  end
end
