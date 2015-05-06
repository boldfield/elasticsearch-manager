require 'colorize'
require 'net/ssh'

require 'elasticsearch/manager/manager'


module Elasticsearch
  module Manager
    module CMD
      include Elasticsearch::Manager

      def self.rolling_restart(opts)
        puts 'Discovering cluster members...'
        manager = _manager(opts)
        # Check that the cluster is stable?
        unless manager.cluster_stable?
          print_cluster_stable(manager)
          return 2
        end
        puts 'Discovering cluster members...'
        manager.cluster_members!
        timeout = opts[:timeout] || 600
        sleep_interval = opts[:sleep_interval] || 30
        begin
          manager.rolling_restart(timeout, sleep_interval)
        rescue Exception => e
          return 2
        end
        puts 'Rolling restart complete.'
        return 0
      end
  
      def self.status(opts)
        manager = _manager(opts)
        status = manager.cluster_status
        puts "The Elasticsearch cluster is currently: #{status.colorize(status.to_sym)}"
      end

      protected
      def self._manager(opts)
        ESManager.new(opts[:hostname], opts[:port])
      end

      def self.print_cluster_stable(manager)
        health = manager.health
        puts 'The cluster is currently unstable! Not proceeding with rolling-restart'
        puts "\tCluster status: #{health.status.colorize(health.status.to_sym)}"

        relocating = health.relocating_shards == 0 ? :green : :red
        puts "\tRelocating shards: #{health.relocating_shards.to_s.colorize(relocating)}"

        initializing = health.initializing_shards == 0 ? :green : :red
        puts "\tInitializing shards: #{health.relocating_shards.to_s.colorize(relocating)}"

        unassigned = health.unassigned_shards == 0 ? :green : :red
        puts "\tUnassigned shards: #{health.relocating_shards.to_s.colorize(relocating)}"
      end
    end
  end
end
