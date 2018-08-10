require_relative 'inspec_tools/inspec'
require_relative 'inspec_tools/xccdf'
require_relative 'inspec_tools/csv'
require_relative 'inspec_tools/pdf'
require_relative 'inspec_tools/ckl'
require_relative 'happy_mapper_tools/benchmark'
require_relative 'happy_mapper_tools/stig_checklist'
require_relative 'utilities/inspec_util'
require_relative 'inspec_tools/version'

# Converter tools for Inspec
module InspecTools
  def self.inspec(inspec_json)
    Inspec.new(inspec_json)
  end
end
