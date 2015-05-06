require 'colorize'
require 'net/ssh'
require 'timeout'
require 'highline'

require 'elasticsearch/manager/manager'


module Elasticsearch
  module Manager
    class StabalizationTimeout < StandardError
    end
    class UserRequestedStop < StandardError
    end


    class ESManager
      def rolling_restart(timeout = 600, sleep_interval = 30)
        highline = HighLine.new
        @members.each do |m|
          restart_node(m, timeout, sleep_interval) unless m == @leader
          if m != @members[-1]
            unless highline.agree('Continue with rolling restart of cluster? (yes/no) ')
              raise UserRequestedStop, "Stopping rolling restart at user request!".colorize(:red)
            end
          end
        end
        unless highline.agree("\nRestarting current cluster master, continue? (yes/no) ")
          raise UserRequestedStop, "Stopping rolling restart at user request before restarting master node!".colorize(:red)
        end
        restart_node(@leader, timeout, sleep_interval)
      end

      def restart_node(node_ip, timeout, sleep_interval)
          puts "\nRestarting Elasticsearch on node: #{node_ip}"
          raise "Could not disable shard routing prior to restarting node: #{node_ip}".colorize(:red) unless disable_routing
          
          Net::SSH.start(node_ip, ENV['USER']) do |ssh|
            ssh.exec 'sudo service elasticsearch restart'
          end
          puts "Elasticsearch restarted on node: #{node_ip}"
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
    end
  end
end
