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
    end
  end
end
