require 'spec_helper'
require 'elasticsearch/client'

describe 'Elasticsearch::Client::Base' '#_build_url' do
  context 'building urls' do
    it 'returns the full URL from passed path and defaults' do
      c = Elasticsearch::Client::Base.new
      path = '/test/path'
      exp_url = "http://localhost:9200#{path}"
      url = c.send('_build_url'.to_sym, path)
      expect(url).to eql(exp_url)
    end

    it 'returns the full URL from passed path and specified host/port' do
      host, port = 'example.com', 9100
      c = Elasticsearch::Client::Base.new(host, port)
      path = '/test/path'
      exp_url = "http://#{host}:#{port}#{path}"
      url = c.send('_build_url'.to_sym, path)
      expect(url).to eql(exp_url)
    end
  end
end

describe 'Elasticsearch::Client::Base' '#_get' do
  context 'simple get' do
    it 'returns raw response from request' do
      c = Elasticsearch::Client::Base.new
      resp = c._get('/base/client')
      expect(resp).to eql('requested: /base/client')
    end
  end
end
