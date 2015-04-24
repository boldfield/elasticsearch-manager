require 'spec_helper'

require 'net/ssh'
require 'elasticsearch/manager/cmd'

include Elasticsearch::Manager

describe 'Elasticsearch::Manager::CMD' '#rolling_restart' do
  let (:ssh_connection) { double("SSH Connection") }

  before do
    allow(Net::SSH).to receive(:start).and_yield(ssh_connection)
  end

  context 'restart cluster' do
    it 'does a clean restart' do
      expect(Net::SSH).to receive(:start).with('10.110.33.218', ENV['USER']).ordered
      expect(Net::SSH).to receive(:start).with('10.110.38.153', ENV['USER']).ordered
      expect(Net::SSH).to receive(:start).with('10.110.40.133', ENV['USER']).ordered

      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end
      expect(ssh_connection).to receive(:exec).exactly(3).times

      exit_code = -1
      output = capture_stdout do
        exit_code = CMD.rolling_restart({:hostname => 'localhost', :port => '9200'})
      end
      expect(exit_code).to eql(0)
    end

    it 'throws stabilization timeout' do
      allow(ssh_connection).to receive(:exec) do |arg|
        expect(arg).to eql('sudo service elasticsearch restart')
      end
      opts = {:hostname => 'localhost-cmd-restart-timeout', :port => '9200', :timeout => 2}
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
      opts = {:hostname => 'localhost-cmd-restart-stabilization', :port => '9200', :timeout => 3}
      exit_code = -1
      output = capture_stdout do
        exit_code = CMD.rolling_restart(opts)
      end
      expect(exit_code).to eql(0)
    end
  end
end
