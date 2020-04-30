require 'date'
require 'json'
require 'cgi'
require 'csv'
require 'yaml'
require 'pp'
require_relative '../happy_mapper_tools/stig_attributes'
require_relative '../happy_mapper_tools/stig_checklist'
require_relative '../happy_mapper_tools/benchmark'
require_relative '../utilities/inspec_util'
require_relative 'csv'

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/BlockLength
# rubocop:disable Style/GuardClause

module InspecTools
  class Inspec
    def initialize(inspec_json, metadata = '{}')
      @json = JSON.parse(inspec_json.gsub(/\\+u0000/, ''))
      @metadata = JSON.parse(metadata)
    end

    def to_ckl(title = nil, date = nil, cklist = nil)
      @data = Utils::InspecUtil.parse_data_for_ckl(@json)
      @platform = Utils::InspecUtil.get_platform(@json)
      @title = generate_title title, @json, date
      @cklist = cklist
      @checklist = HappyMapperTools::StigChecklist::Checklist.new
      if @cklist.nil?
        generate_ckl
      else
        update_ckl
      end
      @checklist.to_xml.encode('UTF-8').gsub('<?xml version="1.0"?>', '<?xml version="1.0" encoding="UTF-8"?>').chomp
    end

    def to_xccdf(attributes, verbose = false)
      @data = Utils::InspecUtil.parse_data_for_xccdf(@json)
      @attribute = attributes
      @attribute = {} if @attribute.eql? false
      @verbose = verbose
      @benchmark = HappyMapperTools::Benchmark::Benchmark.new
      populate_header
      # populate_profiles @todo populate profiles; not implemented now because its use is deprecated
      populate_groups
      @benchmark.to_xml
    end

    ####
    # converts an InSpec JSON to a CSV file
    ###
    def to_csv
      @data = {}
      @data['controls'] = []
      get_all_controls_from_json(@json)
      data = inspec_json_to_array(@data)
      CSV.generate do |csv|
        data.each do |row|
          csv << row
        end
      end
    end

    private

    ###
    #  This method converts an inspec json to an array of arrays
    #
    # @param inspec_json : an inspec profile formatted as a json object
    ###
    def inspec_json_to_array(inspec_json)
      data = []
      headers = {}
      inspec_json['controls'].each do |control|
        control.each do |key, _|
          control['tags'].each { |tag, _| headers[tag] = 0 } if key == 'tags'
          control['results'].each { |result| result.each { |result_key, _| headers[result_key] = 0 } } if key == 'results'
          headers[key] = 0 unless %w{tags results}.include?(key)
        end
      end
      data.push(headers.keys)
      inspec_json['controls'].each do |json_control|
        control = []
        headers.each do |key, _|
          control.push(json_control[key] || json_control['tags'][key] || json_control['results']&.collect { |result| result[key] }&.join(",\n") || nil)
        end
        data.push(control)
      end
      data
    end

    def get_all_controls_from_json(json)
      json['profiles']&.each do |profile|
        profile['controls'].each do |control|
          @data['controls'] << control
        end
      end
      if json['profiles'].nil?
        json['controls'].each do |control|
          @data['controls'] << control
        end
      end
    end

    def update_ckl
      @checklist = HappyMapperTools::StigChecklist::Checklist.parse(@cklist.to_s)
      @data.keys.each do |control_id|
        vuln = @checklist.where('Vuln_Num', control_id.to_s)
        vuln.status = Utils::InspecUtil.control_status(@data[control_id])
        vuln.finding_details << Utils::InspecUtil.control_finding_details(@data[control_id], vuln.status)
      end
    end

    def generate_ckl
      stigs = HappyMapperTools::StigChecklist::Stigs.new
      istig = HappyMapperTools::StigChecklist::IStig.new

      vuln_list = []
      @data.keys.each do |control_id|
        vuln_list.push(generate_vuln_data(@data[control_id]))
      end

      si_data = HappyMapperTools::StigChecklist::SiData.new
      si_data.name = 'stigid'
      si_data.data = ''
      if !@metadata['stigid'].nil?
        si_data.data = @metadata['stigid']
      end

      stig_info = HappyMapperTools::StigChecklist::StigInfo.new
      stig_info.si_data = si_data
      istig.stig_info = stig_info

      istig.vuln = vuln_list
      stigs.istig = istig
      @checklist.stig = stigs

      @checklist.asset = generate_asset
    end

    def generate_vuln_data(control)
      vuln = HappyMapperTools::StigChecklist::Vuln.new
      stig_data_list = []

      %w{Vuln_Num Group_Title Rule_ID Rule_Ver Rule_Title Vuln_Discuss Check_Content Fix_Text}.each do |attribute|
        stig_data_list << create_stig_data_element(attribute, control)
      end
      stig_data_list << handle_severity(control)
      stig_data_list += handle_cci_ref(control)
      stig_data_list << handle_stigref

      vuln.stig_data = stig_data_list.reject!(&:nil?)
      vuln.status = Utils::InspecUtil.control_status(control)
      vuln.comments = "\nAutomated compliance tests brought to you by the MITRE corporation and the InSpec project.\n\nInspec Profile: #{control[:profile_name]}\nProfile shasum: #{control[:profile_shasum]}"
      vuln.finding_details = Utils::InspecUtil.control_finding_details(control, vuln.status)
      vuln.severity_override = ''
      vuln.severity_justification = ''

      vuln
    end

    def generate_asset
      asset = HappyMapperTools::StigChecklist::Asset.new
      asset.role = !@metadata['role'].nil? ? @metadata['role'] : 'Workstation'
      asset.type = !@metadata['type'].nil? ? @metadata['type'] : 'Computing'
      asset.host_name = generate_hostname
      asset.host_ip = generate_ip
      asset.host_mac = generate_mac
      asset.host_fqdn = generate_fqdn
      asset.tech_area = !@metadata['tech_area'].nil? ? @metadata['tech_area'] : ''
      asset.target_key = !@metadata['target_key'].nil? ? @metadata['target_key'] : ''
      asset.web_or_database = !@metadata['web_or_database'].nil? ? @metadata['web_or_database'] : '0'
      asset.web_db_site = !@metadata['web_db_site'].nil? ? @metadata['web_db_site'] : ''
      asset.web_db_instance = !@metadata['web_db_instance'].nil? ? @metadata['web_db_instance'] : ''
      asset
    end

    def generate_hostname
      hostname = @metadata['hostname']
      if hostname.nil? && @platform.nil?
        hostname = ''
      elsif hostname.nil?
        hostname = @platform[:hostname]
      end
      hostname
    end

    def generate_mac
      mac = @metadata['mac']
      if mac.nil?
        nics = @platform.nil? ? [] : @platform[:network]
        nics_macs = []
        nics.each do |nic|
          nics_macs.push(nic[:mac])
        end
        mac = nics_macs.join(',')
      end
      mac
    end

    def generate_fqdn
      fqdn = @metadata['fqdn']
      if fqdn.nil? && @platform.nil?
        fqdn = ''
      elsif fqdn.nil?
        fqdn = @platform[:fqdn]
      end
      fqdn
    end

    def generate_ip
      ip = @metadata['ip']
      if ip.nil?
        nics = @platform.nil? ? [] : @platform[:network]
        nics_ips = []
        nics.each do |nic|
          nics_ips.push(*nic[:ip])
        end
        ip = nics_ips.join(',')
      end
      ip
    end

    def populate_header
      @benchmark.title = @attribute['benchmark.title']
      @benchmark.id = @attribute['benchmark.id']
      @benchmark.description = @attribute['benchmark.description']
      @benchmark.version = @attribute['benchmark.version']

      @benchmark.status = HappyMapperTools::Benchmark::Status.new
      @benchmark.status.status = @attribute['benchmark.status']
      @benchmark.status.date = @attribute['benchmark.status.date']

      @benchmark.notice = HappyMapperTools::Benchmark::Notice.new
      @benchmark.notice.id = @attribute['benchmark.notice.id']

      @benchmark.plaintext = HappyMapperTools::Benchmark::Plaintext.new
      @benchmark.plaintext.plaintext = @attribute['benchmark.plaintext']
      @benchmark.plaintext.id = @attribute['benchmark.plaintext.id']

      @benchmark.reference = HappyMapperTools::Benchmark::ReferenceBenchmark.new
      @benchmark.reference.href = @attribute['reference.href']
      @benchmark.reference.dc_publisher = @attribute['reference.dc.publisher']
      @benchmark.reference.dc_source = @attribute['reference.dc.source']
    end

    def populate_groups
      group_array = []
      @data['controls'].each do |control|
        group = HappyMapperTools::Benchmark::Group.new
        group.id = control['id']
        group.title = control['gtitle']
        group.description = "<GroupDescription>#{control['gdescription']}</GroupDescription>"

        group.rule = HappyMapperTools::Benchmark::Rule.new
        group.rule.id = control['rid']
        group.rule.severity = control['severity']
        group.rule.weight = control['rweight']
        group.rule.version = control['rversion']
        group.rule.title = control['title'].tr("\n", ' ')
        group.rule.description = "<VulnDiscussion>#{control['desc'].tr("\n", ' ')}</VulnDiscussion><FalsePositives></FalsePositives><FalseNegatives></FalseNegatives><Documentable>false</Documentable><Mitigations></Mitigations><SeverityOverrideGuidance></SeverityOverrideGuidance><PotentialImpacts></PotentialImpacts><ThirdPartyTools></ThirdPartyTools><MitigationControl></MitigationControl><Responsibility></Responsibility><IAControls></IAControls>"

        group.rule.reference = HappyMapperTools::Benchmark::ReferenceGroup.new
        group.rule.reference.dc_publisher = @attribute['reference.dc.publisher']
        group.rule.reference.dc_title = @attribute['reference.dc.title']
        group.rule.reference.dc_subject = @attribute['reference.dc.subject']
        group.rule.reference.dc_type = @attribute['reference.dc.type']
        group.rule.reference.dc_identifier = @attribute['reference.dc.identifier']

        group.rule.ident = HappyMapperTools::Benchmark::Ident.new
        group.rule.ident.system = 'https://public.cyber.mil/stigs/cci/'
        group.rule.ident.ident = control['cci']

        group.rule.fixtext = HappyMapperTools::Benchmark::Fixtext.new
        group.rule.fixtext.fixref = control['fixref']
        group.rule.fixtext.fixtext = control['fix']

        group.rule.fix = HappyMapperTools::Benchmark::Fix.new
        group.rule.fix.id = control['fixref']

        group.rule.check = HappyMapperTools::Benchmark::Check.new
        group.rule.check.system = control['checkref']
        group.rule.check.content_ref = HappyMapperTools::Benchmark::ContentRef.new
        group.rule.check.content_ref.name = @attribute['content_ref.name']
        group.rule.check.content_ref.href = @attribute['content_ref.href']
        group.rule.check.content = control['check']

        group_array << group
      end
      @benchmark.group = group_array
    end

    def generate_title(title, json, date)
      title ||= "Untitled - Checklist Created from Automated InSpec Results JSON; Profiles: #{json['profiles'].map { |x| x['name'] }.join(' | ')}"
      title + " Checklist Date: #{date || Date.today.to_s}"
    end

    def create_stig_data_element(attribute, control)
      return HappyMapperTools::StigChecklist::StigData.new(attribute, control[attribute.downcase.to_sym]) unless control[attribute.downcase.to_sym].nil?
    end

    def handle_severity(control)
      return if control[:impact].nil?

      value = Utils::InspecUtil.get_impact_string(control[:impact])
      return if value == 'none'

      value = 'high' if value == 'critical'

      HappyMapperTools::StigChecklist::StigData.new('Severity', value)
    end

    def handle_cci_ref(control)
      return [] if control[:cci_ref].nil?

      cci_data = []
      if control[:cci_ref].respond_to?(:each)
        control[:cci_ref].each do |cci_number|
          cci_data << HappyMapperTools::StigChecklist::StigData.new('CCI_REF', cci_number)
        end
        cci_data
      else
        cci_data << HappyMapperTools::StigChecklist::StigData.new('CCI_REF', control[:cci_ref])
      end
    end

    def handle_stigref
      HappyMapperTools::StigChecklist::StigData.new('STIGRef', @title)
    end
  end
end
