require_relative '../happy_mapper_tools/StigAttributes'
require_relative '../happy_mapper_tools/StigChecklist'
require_relative '../utils/inspec_util'
require_relative 'csv'
require 'csv'
require 'json'

module InspecTools
  class Inspec
    def initialize(inspec_json, attribute_yaml)
      @data = JSON.parse(inspec_json)
      # @data = Utils::InspecUtil.parse_inspec_json(@json)
      @attribute = attribute_yaml
    end
    
    def to_ckl
      @checklist = Checklist.new
      if @cklist.nil?
        generate_ckl
      else
        update_ckl_file
      end
      CGI.unescapeHTML(@checklist.to_xml.encode('UTF-8')).gsub('<?xml version="1.0"?>', '<?xml version="1.0" encoding="UTF-8"?>').chomp
    end
    
    def to_xccdf
      @verbose = verbose
  
      @benchmark = HappyMapperTools::Benchmark::Benchmark.new
      @controls = []
      
      populate_header
      # populate_profiles @todo populate profiles; not implemented now beacuse its use is depreciated
      populate_groups
      @branchmark.to_xml
    end
    
    ####
    # converts an InSpec JSON to a CSV file
    ###
    def to_csv
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
        control.each do |key,value| 
          control['tags'].each {|tag, tag_value| headers[tag] = 0 } if key == 'tags'
          headers[key] = 0 unless key == 'tags' 
        end
      end
      data.push(headers.keys)
      inspec_json['controls'].each do |json_control|
        control = []
        headers.each do |key, value|
          control.push(json_control[key.to_s] || json_control['tags'][key.to_s] || nil) 
        end
        p control
        data.push(control)
      end
      data
    end
    
    def clk_status(control)
      status_list = control[:status].uniq
      if status_list.include?('failed')
        result = 'Open'
      elsif status_list.include?('passed')
        result = 'NotAFinding'
      elsif status_list.include?('skipped')
        result = 'Not_Reviewed'
      else
        result = 'Not_Tested'
      end
      if control[:impact].to_f.zero?
        result = 'Not_Applicable'
      end
      result
    end

    def clk_finding_details(control, control_clk_status)
      result = "One or more of the automated tests failed or was inconclusive for the control \n\n #{control[:message].sort.join}" if control_clk_status == 'Open'
      result = "All Automated tests passed for the control \n\n #{control[:message].join}" if control_clk_status == 'NotAFinding'
      result = "Automated test skipped due to known accepted condition in the control : \n\n#{control[:message].join}" if control_clk_status == 'Not_Reviewed'
      result = "Justification: \n #{control[:message].split.join(' ')}" if control_clk_status == 'Not_Applicable'
      result = 'No test available for this control' if control_clk_status == 'Not_Tested'
      result
    end

    def update_ckl_file
      @checklist = Checklist.parse(@cklist.to_s)
      @data.keys.each do |control_id|
        vuln = @checklist.where('Vuln_Num', control_id.to_s)
        vuln.status = clk_status(@data[control_id])
        vuln.finding_details << clk_finding_details(@data[control_id], vuln.status)
      end
    end

    def generate_vuln_data(control)
      vuln = Vuln.new
      stig_data_list = []

      %w{
        Vuln_Num Severity Group_Title Rule_ID Rule_Ver Rule_Title Vuln_Discuss
        Check_Content Fix_Text CCI_REF
      }.each do |param|
        stigdata = StigData.new
        stigdata.attrib = param
        stigdata.data = control[param.downcase.to_sym]
        stig_data_list.push(stigdata)
      end

      stigdata = StigData.new
      stigdata.attrib = 'STIGRef'
      stigdata.data = @title
      stig_data_list.push(stigdata)

      vuln.stig_data = stig_data_list
      vuln.status = clk_status(control)
      vuln.comments = "\nAutomated compliance tests brought to you by the MITRE corporation and the InSpec project.\n\nInspec Profile: #{control[:profile_name]}\nProfile shasum: #{control[:profile_shasum]}"
      vuln.finding_details = clk_finding_details(control, vuln.status)
      vuln.severity_override = ''
      vuln.severity_justification = ''

      vuln
    end

    def generate_title(title, json, date)
      title ||= "Untitled - Checklist Created from Automated InSpec Results JSON; Profiles: #{json['profiles'].map { |x| x['name'] }.join(' | ')}"
      title + " Checklist Date: #{date || Date.today.to_s}"
    end

    def generate_ckl
      stigs = Stigs.new
      istig = IStig.new
      vuln_list = []
      @data.keys.each do |control_id|
        vuln_list.push(generate_vuln_data(@data[control_id]))
      end
      istig.stig_info = StigInfo.new
      istig.vuln = vuln_list
      stigs.istig = istig
      @checklist.stig = stigs
      asset = Asset.new
      asset.type = 'Computing'
      @checklist.asset = asset
    end
    
    def populate_header
      @benchmark.title = @attribute['benchmark.title']
      @benchmark.id =  @attribute['benchmark.id'] 
      @benchmark.description =  @attribute['benchmark.description']
      @benchmark.version =  @attribute['benchmark.version']
  
      @benchmark.status = Status.new
      @benchmark.status.status =  @attribute['benchmark.status'] 
      @benchmark.status.date =  @attribute['benchmark.status.date']
  
      @benchmark.notice = Notice.new
      @benchmark.notice.id =  @attribute['benchmark.notice']
  
      @benchmark.plaintext = Plaintext.new
      @benchmark.plaintext.plaintext =  @attribute['benchmark.plaintext']
      @benchmark.plaintext.id =  @attribute['benchmark.plaintext.id']
  
      @benchmark.reference = ReferenceBenchmark.new
      @benchmark.reference.href = @attribute['reference.href']
      @benchmark.reference.dc_publisher = @attribute['reference.href']
      @benchmark.reference.dc_source = @attribute['reference.dc.source']
    end
    
    def populate_groups
      group_array = []
      @data['controls'].each do |control|
        group = Group.new
        group.id = control['id']
        group.title = control['gtitle']
        group.description = "<GroupDescription>#{control['gdescription']}</GroupDescription>"
        
        group.rule = Rule.new
        group.rule.id = control['rid']
        group.rule.severity = control['severity']
        group.rule.weight = control['rweight']
        group.rule.version = control['rversion']
        group.rule.title = control['title'].gsub(/\n/, ' ')
        group.rule.description = "<VulnDiscussion>#{control['desc'].gsub(/\n/, ' ')}</VulnDiscussion><FalsePositives></FalsePositives><FalseNegatives></FalseNegatives><Documentable>false</Documentable><Mitigations></Mitigations><SeverityOverrideGuidance></SeverityOverrideGuidance><PotentialImpacts></PotentialImpacts><ThirdPartyTools></ThirdPartyTools><MitigationControl></MitigationControl><Responsibility></Responsibility><IAControls></IAControls>"
  
        group.rule.reference = ReferenceGroup.new
        group.rule.reference.dc_publisher = @attribute['reference.dc.publisher']
        group.rule.reference.dc_title = @attribute['reference.dc.title']
        group.rule.reference.dc_subject = @attribute['reference.dc.subject']
        group.rule.reference.dc_type = @attribute['reference.dc.type']
        group.rule.reference.dc_identifier = @attribute['reference.dc.identifier']
  
        group.rule.ident = Ident.new
        group.rule.ident.system = 'http://iase.disa.mil/cci'
        group.rule.ident.ident = control['cci']
  
        group.rule.fixtext = Fixtext.new
        group.rule.fixtext.fixref = control['fixref']
        group.rule.fixtext.fixtext = control['fix']
  
        group.rule.fix = Fix.new
        group.rule.fix.id = control['fixref']
  
        group.rule.check = Check.new
        group.rule.check.system = control['checkref']
        group.rule.check.content_ref = ContentRef.new
        group.rule.check.content_ref.name = @attribute['content_ref.name']
        group.rule.check.content_ref.href = @attribute['content_ref.href']
        group.rule.check.content = control['check']
  
        group_array << group
      end
      @benchmark.group = group_array
    end
  end
end