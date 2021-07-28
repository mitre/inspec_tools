# coding: utf-8

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

begin
  require 'inspec_tools/version'
rescue LoadError
  nil
end

Gem::Specification.new do |spec|
  spec.name          = 'inspec_tools'
  spec.version       =
    begin
      InspecTools::VERSION
    rescue StandardError
      '0.0.0.1.ENOGVB'
    end
  spec.authors       = ['Robert Thew', 'Matthew Dromazos', 'Rony Xavier', 'Aaron Lippold']
  spec.email         = ['saf@mitre.org']
  spec.summary       = 'Converter utils for Inspec'
  spec.description   = 'Converter utils for Inspec that can be included as a gem or used from the command line'
  spec.homepage      = 'https://inspec-tools.mitre.org/'
  spec.license       = 'Apache-2.0'
  spec.files         = Dir.glob('{lib,exe}/**/*').reject! { |file| file.end_with?('.xlsx') } + %w{LICENSE.md Rakefile README.md}
  spec.bindir        = 'exe'
  spec.executables   << 'inspec_tools'
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7'

  spec.add_runtime_dependency 'colorize', '~> 0'
  spec.add_runtime_dependency 'git-lite-version-bump', '>= 0.17.3'
  spec.add_runtime_dependency 'inspec', '>= 4.18.100', '< 5.0'
  spec.add_runtime_dependency 'inspec_objects', '~> 0.1'
  spec.add_runtime_dependency 'nokogiri', '~> 1.8'
  spec.add_runtime_dependency 'nokogiri-happymapper', '~> 0'
  spec.add_runtime_dependency 'OptionParser', '~> 0'
  spec.add_runtime_dependency 'pdf-reader', '~> 2.1'
  spec.add_runtime_dependency 'roo', '~> 2.8'
  spec.add_runtime_dependency 'rubocop', '~> 1.11'
  spec.add_runtime_dependency 'word_wrap', '~> 1.0'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'bundler-audit'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters', '~> 1.4'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.12.1'
  spec.add_development_dependency 'simplecov'
end
