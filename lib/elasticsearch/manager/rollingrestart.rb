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
          puts "Restarting Elasticsearch on node: #{m}"
          raise "Could not disable shard routing prior to restarting node: #{m}".colorize(:red) unless disable_routing
          
          Net::SSH.start(m, ENV['USER']) do |ssh|
            ssh.exec 'sudo service elasticsearch restart'
          end
          puts "Elasticsearch restarted on node: #{m}"
          raise "Could not re-enable shard routing following restart of node: #{m}".colorize(:red) unless enable_routing
          begin
            wait_for_stable(timeout, sleep_interval)
            puts "Cluster stabalized!".colorize(:green)
            unless highline.agree('Continue with rolling restart of cluster? (yes/no) ')
              raise UserRequestedStop, "Stopping rolling restart at user request!".colorize(:red)
            end
          rescue Timeout::Error
            raise StabalizationTimeout, "Cluster not restabalized after waiting #{timeout} seconds...".colorize(:red)
          end
        end
      end

      protected

      def wait_for_stable(timeout = 600, sleep_interval = 30)
        Timeout.timeout(timeout) do
          while !cluster_stable?
            puts "Waiting for cluster to stabalize...".colorize(:yellow)
            sleep(sleep_interval)
          end
        end
      end
    end
  end
end
