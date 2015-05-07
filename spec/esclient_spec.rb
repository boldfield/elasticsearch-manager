require 'spec_helper'
require 'elasticsearch/client'

describe 'Elasticsearch::Client::ESClient ' '#status' do
  context 'check status' do
    it 'returns green' do
      c = Elasticsearch::Client::ESClient.new
      status = c.status
      expect(status).to eql('green')
    end
  end
  context 'is green?' do
    it 'returns true (green)' do
      c = Elasticsearch::Client::ESClient.new
      status = c.green?
      expect(status).to be true
    end

    it 'returns false (yellow)' do
      c = Elasticsearch::Client::ESClient.new('localhost-yellow')
      status = c.green?
      expect(status).to be false
    end

    it 'returns false (red)' do
      c = Elasticsearch::Client::ESClient.new('localhost-red')
      status = c.green?
      expect(status).to be false
    end
  end
end

describe 'Elasticsearch::Client::ESClient ' '#health' do
  context '_cluster/health' do
    it 'returns health hash' do
      c = Elasticsearch::Client::ESClient.new('localhost')
      health = c.health
      exp_health = JSON.parse(File.read(DIR + '/fixtures/health.json'))
      expect(health).to eql(exp_health)
    end
  end
end

describe 'Elasticsearch::Client::ESClient ' '#nodes' do
  context '_nodes' do
    it 'returns nodes hash' do
      c = Elasticsearch::Client::ESClient.new('localhost')
      nodes = c.nodes
      exp_nodes = JSON.parse(File.read(DIR + '/fixtures/nodes_.json'))
      expect(nodes).to eql(exp_nodes)
    end
  end
end

describe 'Elasticsearch::Client::ESClient ' '#state' do
  context '_cluster/state' do
    it 'returns nodes hash' do
      c = Elasticsearch::Client::ESClient.new('localhost')
      state = c.state
      exp_state = JSON.parse(File.read(DIR + '/fixtures/state.json'))
      expect(state).to eql(exp_state)
    end
  end
end
