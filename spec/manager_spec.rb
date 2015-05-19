require 'spec_helper'
require 'stringio'

require 'elasticsearch/manager'
require 'elasticsearch/model'

include Elasticsearch::Manager

describe 'Elasticsearch::Manager::ESManager' '#cluster_green?' do
  context 'check status' do
    it 'returns green' do
      c = ESManager.new
      expect(c.cluster_green?).to be true
    end

    it 'does not return green (yellow)' do
      c = ESManager.new('localhost-yellow')
      expect(c.cluster_green?).to be false
    end

    it 'does not return green (red)' do
      c = ESManager.new('localhost-red')
      expect(c.cluster_green?).to be false
    end
  end
end

describe 'Elasticsearch::Manager::ESManager' '#cluster_health' do
  context 'health model' do
    it 'returns valid model' do
      c = ESManager.new
      health = c.cluster_health

      expect(health.cluster_name).to eql('test_es_cluster')
      expect(health.status).to eql('green')
      expect(health.timed_out).to be(false)
      expect(health.number_of_nodes).to eql(3)
      expect(health.number_of_data_nodes).to eql(3)
      expect(health.active_primary_shards).to eql(8)
      expect(health.active_shards).to eql(16)
      expect(health.relocating_shards).to eql(0)
      expect(health.initializing_shards).to eql(0)
      expect(health.unassigned_shards).to eql(0)
    end
  end
end

describe 'Elasticsearch::Manager::ESManager' '#cluster_members!' do
  context 'cluster members' do
    it 'retrieves cluster members' do
      c = ESManager.new
      c.cluster_members!
      expect(c.leader).to eql('10.110.38.153')
      expect(c.members).to include('10.110.38.153')
      expect(c.members).to include('10.110.33.218')
      expect(c.members).to include('10.110.40.133')
      expect(c.members.length).to eql(3)
    end
  end
end

describe 'Elasticsearch::Manager::ESManager' '#cluster_stable?' do
  context 'stable cluster' do
    it 'cluster green no rebalancing' do
      c = ESManager.new
      expect(c.cluster_stable?).to be true
    end

    it 'cluster yellow no rebalancing' do
      c = ESManager.new('localhost-yellow')
      expect(c.cluster_stable?).to be false
    end

    it 'cluster red no rebalancing' do
      c = ESManager.new('localhost-red')
      expect(c.cluster_stable?).to be false
    end

    it 'cluster green shards realocating' do
      c = ESManager.new('localhost-realocating')
      expect(c.cluster_stable?).to be false
    end

    it 'cluster green shards initializing' do
      c = ESManager.new('localhost-initializing')
      expect(c.cluster_stable?).to be false
    end

    it 'cluster green shards unassigned' do
      c = ESManager.new('localhost-unassigned')
      expect(c.cluster_stable?).to be false
    end
  end
end

describe 'Elasticsearch::Manager::ESManager' 'routing' do
  context 'disable shard routing' do
    it 'succeeds with 200' do
      c = ESManager.new('localhost-route-disabled')
      expect(c.disable_routing).to be true
    end

    it 'fails with 200' do
      c = ESManager.new('localhost-route-enabled')
      expect(c.disable_routing).to be false
    end
  end

  context 'enable shard routing' do
    it 'succeeds with 200' do
      c = ESManager.new('localhost-route-enabled')
      expect(c.enable_routing).to be true
    end

    it 'fails with 200' do
      c = ESManager.new('localhost-route-disabled')
      expect(c.enable_routing).to be false
    end
  end
end

describe 'Elasticsearch::Manager::ESManager' 'routing' do
  let (:ssh_connection) { double("SSH Connection") }

  before do
    allow(Net::SSH).to receive(:start).and_yield(ssh_connection)

    @input    = StringIO.new
    @output   = StringIO.new
    @terminal = HighLine.new(@input, @output)
    allow(HighLine).to receive(:new).and_return(@terminal)
  end

  context 'rolling restart' do

    it 'does a clean restart' do
      expect(Net::SSH).to receive(:start).with('10.110.40.133', ENV['USER']).ordered
      expect(Net::SSH).to receive(:start).with('10.110.33.218', ENV['USER']).ordered
      expect(Net::SSH).to receive(:start).with('10.110.38.153', ENV['USER']).ordered

      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end
      expect(ssh_connection).to receive(:exec).exactly(3).times

      manager = ESManager.new('localhost', '9200')
      manager.cluster_members!

      @input << "y\ny\ny\ny\n"
      @input.rewind

      capture_stdout do
        manager.rolling_restart(5, 1)
      end
    end

    it 'throws stabilization timeout' do
      manager = ESManager.new('localhost-restart-timeout', 9200)
      manager.cluster_members!
      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end

      @input << "y\ny\ny\ny\n"
      @input.rewind

      output = capture_stdout do
        expect { manager.rolling_restart(2, 1) }.to raise_error(Elasticsearch::Manager::StabalizationTimeout)
      end
    end

    it 'throws node available timeout' do
      manager = ESManager.new('localhost-restart-not-available', 9200)
      manager.cluster_members!
      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end

      @input << "y\ny\ny\ny\n"
      @input.rewind

      output = capture_stdout do
        expect { manager.rolling_restart(2, 1) }.to raise_error(Elasticsearch::Manager::NodeAvailableTimeout)
      end
    end

    it 'handles eventual stabilization' do
      manager = ESManager.new('localhost-restart-stabilization', 9200)
      manager.cluster_members!
      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end

      @input << "y\ny\ny\ny\n"
      @input.rewind

      output = capture_stdout do
        expect { manager.rolling_restart(3, 1) }.not_to raise_error
      end
    end

    it 'Allows user to bail' do
      manager = ESManager.new('localhost', 9200)
      manager.cluster_members!
      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end
      opts = {:hostname => 'localhost', :port => '9200'}

      @input << "n\n"
      @input.rewind

      output = capture_stdout do
        expect { manager.rolling_restart(2, 1) }.to raise_error(Elasticsearch::Manager::UserRequestedStop)
      end
    end

    it 'Allows user to bail at master restart' do
      manager = ESManager.new('localhost', 9200)
      manager.cluster_members!
      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end
      opts = {:hostname => 'localhost', :port => '9200'}

      @input << "y\ny\nn\n"
      @input.rewind

      output = capture_stdout do
        expect { manager.rolling_restart(2, 1) }.to raise_error(Elasticsearch::Manager::UserRequestedStop)
      end
    end

    it 'throws settings update error when disabling routing' do
      manager = ESManager.new('localhost-disable-routing-error', 9200)
      manager.cluster_members!
      opts = {:hostname => 'localhost', :port => '9200'}

      @input << "y\n"
      @input.rewind

      output = capture_stdout do
        expect { manager.rolling_restart(2, 1) }.to raise_error(Elasticsearch::Manager::ClusterSettingsUpdateError)
      end
    end

    it 'throws settings update error when updating recovery concurrency' do
      manager = ESManager.new('localhost-update-concurrent-error', 9200)
      manager.cluster_members!
      opts = {:hostname => 'localhost', :port => '9200'}

      @input << "y\n"
      @input.rewind

      output = capture_stdout do
        expect { manager.rolling_restart(2, 1) }.to raise_error(Elasticsearch::Manager::ClusterSettingsUpdateError)
      end
    end

    it 'handles server errors on settings update' do
      manager = ESManager.new('localhost-error-settings', 9200)
      manager.cluster_members!
      opts = {:hostname => 'localhost', :port => '9200'}

      @input << "y\n"
      @input.rewind

      output = capture_stdout do
        expect { manager.rolling_restart(2, 1) }.to raise_error(Elasticsearch::Manager::ApiError)
      end
    end
  end
end
