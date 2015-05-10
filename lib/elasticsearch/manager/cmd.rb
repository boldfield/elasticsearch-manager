require 'colorize'
require 'net/ssh'

require 'elasticsearch/manager/manager'
require 'elasticsearch/manager/rollingrestart'


module Elasticsearch
  module Manager
    module CMD
      include Elasticsearch::Manager

      def self.rolling_restart(opts)
        manager = _manager(opts)
        # Check that the cluster is stable?
        unless manager.cluster_stable?
          print_cluster_status(manager, 'The cluster is currently unstable! Not proceeding with rolling-restart')
          return 2
        end
        puts "Discovering cluster members...\n"
        manager.cluster_members!
        timeout = opts[:timeout] || 600
        sleep_interval = opts[:sleep_interval] || 30
        begin
          manager.rolling_restart(timeout, sleep_interval)
        rescue Exception => e
          puts e
          return 2
        end
        puts 'Rolling restart complete.'
        return 0
      end
  
      def self.list_nodes(opts)
        manager = _manager(opts)
        print "Discovering cluster members..." if opts[:verbose]
        manager.cluster_members!
        print "\rDiscovering cluster members... Done!\n" if opts[:verbose]
        manager.list_node_ips
      end

      def self.status(opts)
        manager = _manager(opts)
        status = manager.cluster_status
        puts "The Elasticsearch cluster is currently: #{status.colorize(status.to_sym)}"
        print_cluster_status(manager) if opts[:verbose]
        return 0
      end

      protected
      def self._manager(opts)
        ESManager.new(opts[:hostname], opts[:port])
      end

      def self.print_cluster_status(manager, msg = nil)
        health = manager.cluster_health
        puts msg unless msg.nil?
        puts "\tCluster status: #{health.status.colorize(health.status.to_sym)}"

        relocating = health.relocating_shards == 0 ? :green : :red
        puts "\tRelocating shards: #{health.relocating_shards.to_s.colorize(relocating)}"

        initializing = health.initializing_shards == 0 ? :green : :red
        puts "\tInitializing shards: #{health.initializing_shards.to_s.colorize(initializing)}"

        unassigned = health.unassigned_shards == 0 ? :green : :red
        puts "\tUnassigned shards: #{health.unassigned_shards.to_s.colorize(unassigned)}"
      end
    end
  end
end
