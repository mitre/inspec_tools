# require 'inspec_tools/ckl'
# require 'inspec_tools/csv'
require 'inspec_tools/inspec'
require 'happy_mapper_tools/benchmark'
require 'happy_mapper_tools/stig_checklist'
require 'utils/inspec_util'
# require 'inspec_tools/xccdf'
# require 'inspec_tools/version'
# require 'inspec_tools'

# Converter tools for Inspec
module InspecTools
  def self.inspec(inspec_json)
    Inspec.new(inspec_json)
  end
end
