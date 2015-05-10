require 'elasticsearch/client'
require 'elasticsearch/model'

module Elasticsearch
  module Manager
    class ESManager
      include Elasticsearch::Model

      attr_accessor :leader, :members, :nodes, :state

      def initialize(cluster_host = 'localhost', port = 9200)
        @client = Elasticsearch::Client::ESClient.new(cluster_host, port)
        @state = nil
        @leader = nil
        @nodes = nil
        @members = nil
      end

      def cluster_green?
        @client.green?
      end

      def cluster_status
        @client.status
      end

      def cluster_stable?
        health = cluster_health
        moving = [health.relocating_shards, health.initializing_shards, health.unassigned_shards]
        cluster_green? && moving.all? { |x| x == 0 } 
      end

      def cluster_members!
        @state = cluster_state
        @nodes = state.nodes
        @leader = @nodes.select { |n| n.master }[0].ip
        @members = @nodes.map { |n| n.ip }
      end

      def cluster_health
        health = @client.health
        Health.new.extend(Health::Representer).from_hash(health)
      end

      def cluster_state
        state = @client.state
        ClusterState.new.extend(ClusterState::Representer).from_hash(state)
      end

      def disable_routing
        ret = @client.routing(true)
        ret['transient']['cluster']['routing']['allocation']['enable'] == 'none'
      end

      def enable_routing
        ret = @client.routing(false)
        ret['transient']['cluster']['routing']['allocation']['enable'] == 'all'
      end
    end
  end
end
