module Elasticsearch
  module Manager
    class StabalizationTimeout < StandardError
    end

    class NodeAvailableTimeout < StandardError
    end

    class UserRequestedStop < StandardError
    end

    class ClusterSettingsUpdateError < StandardError
    end

    class ApiError < StandardError
    end
  end
end
