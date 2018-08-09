require 'inspec_to/inspec_to_ckl'
require 'inspec_to/stig_checklist'

require 'csv2inspec'
#require 'inspec2ckl'
require 'xccdf2inspec'
require 'inspec2xccdf'
#require 'require_all'
#require "inspec_to"

module InspecTo
  # Convert InSpec json to CKL XML
  def self.ckl(inspec_json, cklist=nil, title=nil, date=nil)
     InspecToCkl.new(inspec_json, cklist, title, date).to_ckl
  end
  
  # Convert XCCDF to InSpec JSON
  def self.xccdf2inspec(xccdf_path, cci_path=nil, output='/tmp/profile/', output_format='json', seperated=nil, replace_tags=nil)
     Xccdf2Inspec.new(xccdf_path, cci_path, output, output_format, seperated, replace_tags)
  end
end
