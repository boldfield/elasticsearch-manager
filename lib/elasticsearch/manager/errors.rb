module Elasticsearch
  module Manager
    class StabalizationTimeout < StandardError
    end

    class NodeAvailableTimeout < StandardError
    end

    class UserRequestedStop < StandardError
    end
  end
end
