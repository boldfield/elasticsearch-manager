require 'colorize'
require 'net/ssh'
require 'timeout'

require 'elasticsearch/manager/manager'


module Elasticsearch
  module Manager
    class StabalizationTimeout < StandardError
    end

    class ESManager

      def rolling_restart(timeout = 600)
        @members.each do |m|
          raise "Could not disable shard routing prior to restarting node: #{m}" unless disable_routing
          
          Net::SSH.start(m, ENV['USER']) do |ssh|
            ssh.exec 'sudo service elasticsearch restart'
          end
          raise "Could not re-enable shard routing following restart of node: #{m}" unless enable_routing
          begin
            wait_for_stable(timeout)
          rescue Timeout::Error
            raise StabalizationTimeout, "Cluster not restabalized after waiting #{timeout} seconds..."
          end
        end
      end

      protected

      def wait_for_stable(timeout = 600)
        Timeout.timeout(timeout) do
          while !cluster_stable?
            sleep(1)
          end
        end
      end
    end
  end
end
