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

      def cat_uptime
        resp = get('/_cat/nodes', {'h' => 'ip,uptime'})
        Hash[resp.split("\n").map { |l| l.split }]
      end

      def node_concurrent_recoveries(num_recoveries = 2)
        data = {
          'transient' => {
            'cluster.routing.allocation.node_concurrent_recoveries' => num_recoveries
          }
        }.to_json

        put('/_cluster/settings', data)
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
