require 'inspec_tools/inspec'
require 'inspec_tools/xccdf'
require 'inspec_tools/csv'
require 'inspec_tools/pdf'
require 'inspec_tools/ckl'
require 'happy_mapper_tools/benchmark'
require 'happy_mapper_tools/stig_checklist'
require 'utils/inspec_util'
require 'inspec_tools/version'

# Converter tools for Inspec
module InspecTools
  def self.inspec(inspec_json)
    Inspec.new(inspec_json)
  end
end
