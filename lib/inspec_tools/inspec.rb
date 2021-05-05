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
require_relative '../utilities/xccdf/from_inspec'
require_relative '../utilities/xccdf/to_xccdf'

module InspecTools
  class Inspec # rubocop:disable Metrics/ClassLength
    def initialize(inspec_json, metadata = {})
      @json = JSON.parse(inspec_json.gsub(/\\+u0000/, ''))
      @metadata = metadata
    end

    # converts an InSpec JSON to a Checklist file
    # @param attributes [Hash] Optional input attributes
    def to_ckl(attributes = {}, cklist = nil)
      @data = Utils::InspecUtil.parse_data_for_ckl(@json)
      @platform = Utils::InspecUtil.get_platform(@json)
      @title = generate_title attributes, @json
      @cklist = cklist
      @checklist = HappyMapperTools::StigChecklist::Checklist.new
      if @cklist.nil?
        generate_ckl(attributes)
      else
        update_ckl
      end
      @checklist.to_xml.encode('UTF-8').gsub('<?xml version="1.0"?>', '<?xml version="1.0" encoding="UTF-8"?>').chomp
    end

    # Convert Inspec result data to XCCDF
    #
    # @param attributes [Hash] Optional input attributes
    # @return [String] XML formatted String
    def to_xccdf(attributes, verbose = false)
      data = Utils::FromInspec.new.parse_data_for_xccdf(@json)
      @verbose = verbose

      Utils::ToXCCDF.new(attributes || {}, data).to_xml(@metadata)
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
    def inspec_json_to_array(inspec_json) # rubocop:disable Metrics/CyclomaticComplexity
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

      return unless json['profiles'].nil?

      json['controls'].each do |control|
        @data['controls'] << control
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

    # @param attributes [Hash] Optional input attributes
    def generate_ckl(attributes)
      stigs = HappyMapperTools::StigChecklist::Stigs.new
      istig = HappyMapperTools::StigChecklist::IStig.new

      vuln_list = []
      @data.keys.each do |control_id|
        vuln_list.push(generate_vuln_data(@data[control_id]))
      end

      si_data = []
      si_data << generate_si_data('stigid', @metadata['stigid'] || '')
      si_data << generate_si_data('version', attributes['benchmark.version']) if attributes['benchmark.version']
      si_data << generate_si_data('releaseinfo', attributes['benchmark.plaintext']) if attributes['benchmark.plaintext']
      si_data << generate_si_data('title', attributes['benchmark.title']) if attributes['benchmark.title']

      stig_info = HappyMapperTools::StigChecklist::StigInfo.new
      stig_info.si_data = si_data
      istig.stig_info = stig_info

      istig.vuln = vuln_list
      stigs.istig = istig
      @checklist.stig = stigs

      @checklist.asset = generate_asset
    end

    # Create SI_DATA portion of checklist file
    def generate_si_data(name, data)
      si_data = HappyMapperTools::StigChecklist::SiData.new
      si_data.name = name
      si_data.data = data
      si_data
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

      vuln.stig_data = stig_data_list.reject(&:nil?)
      vuln.status = Utils::InspecUtil.control_status(control)
      vuln.comments = "\nAutomated compliance tests brought to you by the MITRE corporation and the InSpec project.\n\nInspec Profile: #{control[:profile_name]}\nProfile shasum: #{control[:profile_shasum]}"
      vuln.finding_details = Utils::InspecUtil.control_finding_details(control, vuln.status)
      vuln.severity_override = ''
      vuln.severity_justification = ''

      vuln
    end

    def generate_asset # rubocop:disable Metrics/AbcSize
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

    # @param attributes XCCDF attributes from source specification
    def generate_title(attributes, json)
      return "#{attributes['benchmark.title']} :: Version #{attributes['benchmark.version']}, #{attributes['benchmark.plaintext']}" if attributes['benchmark.title']

      title ||= "Untitled - Checklist Created from Automated InSpec Results JSON; Profiles: #{json['profiles'].map { |x| x['name'] }.join(' | ')}"
      title + " Checklist Date: #{Date.today}"
    end

    def create_stig_data_element(attribute, control)
      return HappyMapperTools::StigChecklist::StigData.new(attribute, control[attribute.downcase.to_sym]) unless control[attribute.downcase.to_sym].nil?
    end

    def handle_severity(control)
      return if control[:impact].nil?

      value = Utils::InspecUtil.get_impact_string(control[:impact], use_cvss_terms: false)
      return if value == 'none'

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
