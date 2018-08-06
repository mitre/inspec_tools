require 'inspec_to/inspec_to_ckl'
require 'inspec_to/stig_checklist'
#require 'require_all'
#require "inspec_to"

module InspecTo
  # Convert Inspec json to CKL XML
  def self.ckl(inspec_json, cklist=nil, title=nil, date=nil)
     InspecToCkl.new(inspec_json, cklist, title, date).to_ckl
  end
end
