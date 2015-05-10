require 'colorize'
require 'net/ssh'
require 'timeout'
require 'highline'

require 'elasticsearch/manager/errors'
require 'elasticsearch/manager/manager'


module Elasticsearch
  module Manager

    class ESManager
      def rolling_restart(timeout = 600, sleep_interval = 30)
        highline = HighLine.new
        @members.each do |m|
          unless m == @leader
            unless highline.agree('Continue with rolling restart of cluster? (y/n) ')
              raise UserRequestedStop, "Stopping rolling restart at user request!".colorize(:red)
            end
            restart_node(m, timeout, sleep_interval)
          end
        end
        unless highline.agree("\nRestarting current cluster master, continue? (y/n) ")
          raise UserRequestedStop, "Stopping rolling restart at user request before restarting master node!".colorize(:red)
        end
        restart_node(@leader, timeout, sleep_interval)
      end

      def restart_node(node_ip, timeout, sleep_interval)
          puts "\nRestarting Elasticsearch on node: #{node_ip}"
          # Pull the current node's state
          n = @state.nodes.select { |n| n.ip == node_ip }[0]

          raise "Could not disable shard routing prior to restarting node: #{node_ip}".colorize(:red) unless disable_routing
          Net::SSH.start(node_ip, ENV['USER']) do |ssh|
            ssh.exec 'sudo service elasticsearch restart'
          end
          puts "Elasticsearch restarted on node: #{node_ip}"

          begin
            wait_for_node_available(node_ip, timeout, sleep_interval)
            puts "Node back up!".colorize(:green)
          rescue Timeout::Error
            raise NodeAvailableTimeout, "Node did not become available after waiting #{timeout} seconds...".colorize(:red)
          end

          # Make sure the cluster is willing to concurrently recover as many
          # shards per node as this node happens to have.
          raise "Could not update node_concurrent_recoveries prior to restarting node: #{node_ip}".colorize(:red) unless set_concurrent_recoveries(n.count_started_shards + 1)

          raise "Could not re-enable shard routing following restart of node: #{node_ip}".colorize(:red) unless enable_routing

          begin
            wait_for_stable(timeout, sleep_interval)
            puts "Cluster stabilized!".colorize(:green)
          rescue Timeout::Error
            raise StabalizationTimeout, "Cluster not re-stabilize after waiting #{timeout} seconds...".colorize(:red)
          end
      end 

      protected

      def wait_for_stable(timeout = 600, sleep_interval = 30)
        Timeout.timeout(timeout) do
          while !cluster_stable?
            puts "Waiting for cluster to stabilize...".colorize(:yellow)
            sleep(sleep_interval)
          end
        end
      end

      def wait_for_node_available(node_ip, timeout = 600, sleep_interval = 30)
        Timeout.timeout(timeout) do
          state = cluster_state
          while !state.nodes.map { |n| n.ip }.include?(node_ip)
            puts "Waiting for node to become available...".colorize(:yellow)
            sleep(sleep_interval)
            state = cluster_state
          end
        end
      end
    end
  end
end
