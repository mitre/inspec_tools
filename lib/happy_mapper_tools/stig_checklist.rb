#!/usr/local/bin/ruby
# encoding: utf-8
# author: Aaron Lippold
# author: Rony Xavier rx294@nyu.edu

require 'happymapper'
require 'nokogiri'

module HappyMapperTools
  # see: https://github.com/dam5s/happymapper
  # Class Asset maps from the 'Asset' from Checklist XML file using HappyMapper
  class Asset
    include HappyMapper
    tag 'ASSET'
    element :role, String, tag: 'ROLE'
    element :type, String, tag: 'ASSET_TYPE'
    element :host_name, String, tag: 'HOST_NAME'
    element :host_ip, String, tag: 'HOST_IP'
    element :host_mac, String, tag: 'HOST_MAC'
    element :host_guid, String, tag: 'HOST_GUID'
    element :host_fqdn, String, tag: 'HOST_FQDN'
    element :tech_area, String, tag: 'TECH_AREA'
    element :target_key, String, tag: 'TARGET_KEY'
    element :web_or_database, String, tag: 'WEB_OR_DATABASE'
    element :web_db_site, String, tag: 'WEB_DB_SITE'
    element :web_db_instance, String, tag: 'WEB_DB_INSTANCE'
  end

  # Class Asset maps from the 'SI_DATA' from Checklist XML file using HappyMapper
  class SiData
    include HappyMapper
    tag 'SI_DATA'
    element :name, String, tag: 'SID_NAME'
    element :data, String, tag: 'SID_DATA'
  end

  # Class Asset maps from the 'STIG_INFO' from Checklist XML file using HappyMapper
  class StigInfo
    include HappyMapper
    tag 'STIG_INFO'
    has_many :si_data, SiData, tag: 'SI_DATA'
  end

  # Class Asset maps from the 'STIG_DATA' from Checklist XML file using HappyMapper
  class StigData
    include HappyMapper
    tag 'STIG_DATA'
    has_one :attrib, String, tag: 'VULN_ATTRIBUTE'
    has_one :data, String, tag: 'ATTRIBUTE_DATA'
  end

  # Class Asset maps from the 'VULN' from Checklist XML file using HappyMapper
  class Vuln
    include HappyMapper
    tag 'VULN'
    has_many :stig_data, StigData, tag:'STIG_DATA'
    has_one :status, String, tag: 'STATUS'
    has_one :finding_details, String, tag: 'FINDING_DETAILS'
    has_one :comments, String, tag: 'COMMENTS'
    has_one :severity_override, String, tag: 'SEVERITY_OVERRIDE'
    has_one :severity_justification, String, tag: 'SEVERITY_JUSTIFICATION'
  end

  # Class Asset maps from the 'iSTIG' from Checklist XML file using HappyMapper
  class IStig
    include HappyMapper
    tag 'iSTIG'
    has_one :stig_info, StigInfo, tag: 'STIG_INFO'
    has_many :vuln, Vuln, tag: 'VULN'
  end

  # Class Asset maps from the 'STIGS' from Checklist XML file using HappyMapper
  class Stigs
    include HappyMapper
    tag 'STIGS'
    has_one :istig, IStig, tag: 'iSTIG'
  end

  class Checklist
    include HappyMapper
    tag 'CHECKLIST'
    has_one :asset, Asset, tag: 'ASSET'
    has_one :stig, Stigs, tag: 'STIGS'
    Encoding.default_external = 'UTF-8'

    def where(attrib, data)
      stig.istig.vuln.each do |vuln|
        if vuln.stig_data.any? { |element| element.attrib == attrib && element.data == data}
          # todo Handle multiple objects that match the condition
          return vuln
        end
      end
    end
  end
end
