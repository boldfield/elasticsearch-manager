module Elasticsearch
  module Manager

    class ESManager
      def list_node_ips
        puts "#{@leader} -- master"
        @members.each do |m|
          unless m == @leader
            puts m
          end
        end
      end
      def list_node_uptime
        node_uptime
        @nodes.each do |n|
          print "#{n.ip} -- #{n.uptime} seconds"
          print "\n"
        end
      end

      def node_uptime
        node_uptime = @client.cat_uptime
        @nodes.each do |n|
          ut = parse_uptime(node_uptime[n.ip]).to_i
          n.uptime = ut
        end
      end
    end
  end
end
