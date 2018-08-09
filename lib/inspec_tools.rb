#<<<<<<< HEAD
require 'inspec_tools/inspec'
require 'happy_mapper_tools/benchmark'
require 'happy_mapper_tools/stig_checklist'
require 'utils/inspec_util'
require 'inspec_tools/version'

#=======
#require_relative 'inspec_tools/ckl'
#require_relative 'inspec_tools/csv'
#require_relative 'inspec_tools/inspec'
#require_relative 'inspec_tools/xccdf'
#require_relative 'inspec_tools/version'
#>>>>>>> 525f0378b3fad0e10e11e5d4141e77233516b954

# Converter tools for Inspec
module InspecTools
  def self.inspec(inspec_json)
    Inspec.new(inspec_json)
  end
end
