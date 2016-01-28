# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elasticsearch/manager/version'

Gem::Specification.new do |spec|
  spec.name          = 'elasticsearch-manager'
  spec.version       = Elasticsearch::Manager::VERSION
  spec.authors       = ['Brian Oldfield']
  spec.email         = ['brian@oldfield.io']
  spec.summary       = %q{Basic managment utility for Elasticsearch}
  spec.description   = %q{Basic managment utility for Elasticsearch}
  spec.homepage      = 'http://github.com/boldfield/elasticsearch-manager'
  spec.license       = 'Apache'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'simplecov', '~> 0.9'
  spec.add_development_dependency 'webmock', '~> 1.21'
  spec.add_development_dependency 'rack', '~> 1.6'
  spec.add_dependency 'rest-client', '~> 1.8'
  spec.add_dependency 'representable', '~> 2.1'
  spec.add_dependency 'json', '~> 1.8'
  spec.add_dependency 'highline', '~> 1.7'
  spec.add_dependency 'net-ssh', '~> 2.9'
  spec.add_dependency 'colorize', '~> 0.7'
end
