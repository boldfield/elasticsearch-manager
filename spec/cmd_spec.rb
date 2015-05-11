require 'spec_helper'
require 'stringio'

require 'net/ssh'
require 'elasticsearch/manager/cmd'

include Elasticsearch::Manager

describe 'Elasticsearch::Manager::CMD' '#rolling_restart' do
  let (:ssh_connection) { double("SSH Connection") }

  before do
    allow(Net::SSH).to receive(:start).and_yield(ssh_connection)

    @input    = StringIO.new
    @output   = StringIO.new
    @terminal = HighLine.new(@input, @output)
    allow(HighLine).to receive(:new).and_return(@terminal)
  end

  context 'restart cluster' do
    it 'does a clean restart' do
      expect(Net::SSH).to receive(:start).with('10.110.40.133', ENV['USER']).ordered
      expect(Net::SSH).to receive(:start).with('10.110.33.218', ENV['USER']).ordered
      expect(Net::SSH).to receive(:start).with('10.110.38.153', ENV['USER']).ordered

      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end
      expect(ssh_connection).to receive(:exec).exactly(3).times

      @input << "y\ny\ny\n"
      @input.rewind

      exit_code = -1
      output = capture_stdout do
        opts = {:hostname => 'localhost', :port => '9200', :sleep_interval => 1 }
        exit_code = CMD.rolling_restart(opts)
      end
      expect(exit_code).to eql(0)
    end

    it 'throws stabilization timeout' do
      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end
      opts = {:hostname => 'localhost-cmd-restart-timeout', :port => '9200', :timeout => 2, :sleep_interval => 1}

      @input << "y\ny\ny\n"
      @input.rewind

      exit_code = -1
      output = capture_stdout do
        exit_code = CMD.rolling_restart(opts)
      end
      expect(exit_code).to eql(2)
    end

    it 'throws node available timeout' do
      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end
      opts = {:hostname => 'localhost-cmd-restart-not-available', :port => '9200', :timeout => 2, :sleep_interval => 1}

      @input << "y\ny\ny\n"
      @input.rewind

      exit_code = -1
      output = capture_stdout do
        exit_code = CMD.rolling_restart(opts)
      end
      expect(exit_code).to eql(2)
    end

    it 'handles eventual stabilization' do
      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end
      opts = {:hostname => 'localhost-cmd-restart-stabilization', :port => '9200', :timeout => 3, :sleep_interval => 1}

      @input << "y\ny\ny\n"
      @input.rewind

      exit_code = -1
      output = capture_stdout do
        exit_code = CMD.rolling_restart(opts)
      end
      expect(exit_code).to eql(0)
    end

    it 'Allows user to bail' do
      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end
      opts = {:hostname => 'localhost', :port => '9200'}

      @input << "no\n"
      @input.rewind

      exit_code = -1
      output = capture_stdout do
        exit_code = CMD.rolling_restart(opts)
      end
      expect(exit_code).to eql(2)
    end

    it 'Allows user to bail at master restart' do
      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end
      opts = {:hostname => 'localhost', :port => '9200'}

      @input << "y\ny\nn\n"
      @input.rewind

      exit_code = -1
      output = capture_stdout do
        exit_code = CMD.rolling_restart(opts)
      end
      expect(exit_code).to eql(2)
    end

    it 'throws settings update error when disabling routing' do
      opts = {:hostname => 'localhost-disable-routing-error', :port => '9200'}

      @input << "y\n"
      @input.rewind

      exit_code = -1
      output = capture_stdout do
        exit_code = CMD.rolling_restart(opts)
      end
      expect(exit_code).to eql(2)
    end

    it 'throws settings update error when updating recovery concurrency' do
      opts = {:hostname => 'localhost-update-concurrent-error', :port => '9200'}

      @input << "y\n"
      @input.rewind

      exit_code = -1
      output = capture_stdout do
        exit_code = CMD.rolling_restart(opts)
      end
      expect(exit_code).to eql(2)
    end

    it 'handles server errors on settings update' do
      opts = {:hostname => 'localhost-error-settings', :port => '9200'}

      @input << "y\n"
      @input.rewind

      exit_code = -1
      output = capture_stdout do
        exit_code = CMD.rolling_restart(opts)
      end
      expect(exit_code).to eql(3)
    end

    it 'handles server errors on state request' do
      opts = {:hostname => 'localhost-error-state', :port => '9200'}

      @input << "y\n"
      @input.rewind

      exit_code = -1
      output = capture_stdout do
        exit_code = CMD.rolling_restart(opts)
      end
      expect(exit_code).to eql(3)
    end

    it 'handles server errors on health request' do
      opts = {:hostname => 'localhost-error-health', :port => '9200'}

      @input << "y\n"
      @input.rewind

      exit_code = -1
      output = capture_stdout do
        exit_code = CMD.rolling_restart(opts)
      end
      expect(exit_code).to eql(3)
    end
  end
end
