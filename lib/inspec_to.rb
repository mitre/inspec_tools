require 'inspec_to/inspec_to_ckl'
require 'inspec_to/stig_checklist'

require 'csv2inspec'
#require 'inspec2ckl'
require 'xccdf2inspec'
require 'inspec2xccdf'
#require 'require_all'
#require "inspec_to"

module InspecTo
  # Convert Inspec json to CKL XML
  def self.ckl(inspec_json, cklist=nil, title=nil, date=nil)
     InspecToCkl.new(inspec_json, cklist, title, date).to_ckl
  end
end
