# coding: utf-8

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'inspec_tools/version'

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name          = 'inspec_tools'
  spec.version       = InspecTools::VERSION
  spec.authors       = ['Robert Thew', 'Matthew Dromazos', 'Rony Xavier', 'Aaron Lippold']
  spec.email         = ['rthew@mitre.org']
  spec.summary       = 'Converter utils for Inspec'
  spec.description   = 'Converter utils for Inspec that can be included as a gem or used from the command line'
  spec.homepage      = 'https://github.com/mitre/inspec_tools'
  spec.license       = 'Apache-2.0'

  spec.files         = Dir.glob('{lib,exe}/**/*') + %w{CHANGELOG.md Guardfile LICENSE.md Rakefile README.md}
  spec.bindir        = 'exe'
  spec.executables   << 'inspec_tools'
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.4'

  spec.add_runtime_dependency 'colorize', '~> 0'
  spec.add_runtime_dependency 'inspec', ">= 3.0", "< 5.0"
  spec.add_runtime_dependency 'inspec-objects'
  spec.add_runtime_dependency 'nokogiri', '~> 1.8'
  spec.add_runtime_dependency 'nokogiri-happymapper', '~> 0'
  spec.add_runtime_dependency 'OptionParser', '~> 0'
  spec.add_runtime_dependency 'pdf-reader', '~> 2.1', '>= 2.1.0'
  spec.add_runtime_dependency 'roo', '~> 2.8'
  spec.add_runtime_dependency 'thor', '~> 0.19'
  spec.add_runtime_dependency 'word_wrap', '~> 1.0'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'simplecov'
end
