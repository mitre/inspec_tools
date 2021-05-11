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
require_relative '../utilities/xccdf/xccdf_score'

module InspecTools
  class Inspec
    DATA_NOT_FOUND_MESSAGE = 'N/A'.freeze

    def initialize(inspec_json, metadata = {})
      @json = JSON.parse(inspec_json)
      @metadata = metadata
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

    # Convert Inspec result data to XCCDF
    #
    # @param attributes [Hash] Optional input attributes
    # @return [String] XML formatted String
    def to_xccdf(attributes, verbose = false)
      data = parse_data_for_xccdf(@json)
      @verbose = verbose
      @benchmark = HappyMapperTools::Benchmark::Benchmark.new

      to_xml(@metadata, attributes, data)
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

    def topmost_profile_name
      find_topmost_profile_name(0)
    end

    def find_topmost_profile_name(index, parent_name = nil)
      # Return nil when the index is out of bounds.
      # nil returned here will set the profile name to '' in the calling functions.
      return nil if index > @json['profiles'].length - 1

      # No parent profile means this is the parent
      if !@json['profiles'][index].key?('parent_profile') && (@json['profiles'][index]['name'] == parent_name || index.zero?)
        # For the initial case, parent_name will be nil, and if we are already at the parent index is also zero
        return @json['profiles'][index]['name']
      end

      parent_name = @json['profiles'][index]['parent_profile']
      find_topmost_profile_name(index + 1, parent_name)
    end

    # Build entire XML document and produce final output
    # @param metadata [Hash] Data representing a system under scan
    def to_xml(metadata, attributes, data)
      attributes = {} if attributes.nil?
      build_benchmark_header(attributes)
      build_groups(attributes, data)
      # Only populate results if a target is defined so that conformant XML is produced.
      @benchmark.testresult = build_test_results(metadata, data) if metadata['fqdn']
      @benchmark.to_xml
    end

    def build_benchmark_header(attributes)
      @benchmark.title = attributes['benchmark.title']
      @benchmark.id = attributes['benchmark.id']
      @benchmark.description = attributes['benchmark.description']
      @benchmark.version = attributes['benchmark.version']
      @benchmark.xmlns = 'http://checklists.nist.gov/xccdf/1.1'

      @benchmark.status = HappyMapperTools::Benchmark::Status.new
      @benchmark.status.status = attributes['benchmark.status']
      @benchmark.status.date = attributes['benchmark.status.date']

      if attributes['benchmark.notice.id']
        @benchmark.notice = HappyMapperTools::Benchmark::Notice.new
        @benchmark.notice.id = attributes['benchmark.notice.id']
      end

      if attributes['benchmark.plaintext'] || attributes['benchmark.plaintext.id']
        @benchmark.plaintext = HappyMapperTools::Benchmark::Plaintext.new
        @benchmark.plaintext.plaintext = attributes['benchmark.plaintext']
        @benchmark.plaintext.id = attributes['benchmark.plaintext.id']
      end

      @benchmark.reference = HappyMapperTools::Benchmark::ReferenceBenchmark.new
      @benchmark.reference.href = attributes['reference.href']
      @benchmark.reference.dc_publisher = attributes['reference.dc.publisher']
      @benchmark.reference.dc_source = attributes['reference.dc.source']
    end

    # Translate join of Inspec results and input attributes to XCCDF Groups
    def build_groups(attributes, data)
      group_array = []
      data['controls'].each do |control|
        group = HappyMapperTools::Benchmark::Group.new
        group.id = control['id']
        group.title = control['gtitle']
        group.description = "<GroupDescription>#{control['gdescription']}</GroupDescription>" if control['gdescription']

        group.rule = HappyMapperTools::Benchmark::Rule.new
        group.rule.id = control['rid']
        group.rule.severity = control['severity']
        group.rule.weight = control['rweight']
        group.rule.version = control['rversion']
        group.rule.title = control['title'].tr("\n", ' ') if control['title']
        group.rule.description = "<VulnDiscussion>#{control['desc']}</VulnDiscussion><FalsePositives></FalsePositives><FalseNegatives></FalseNegatives><Documentable>false</Documentable><Mitigations>#{control['rationale']}</Mitigations><SeverityOverrideGuidance></SeverityOverrideGuidance><PotentialImpacts></PotentialImpacts><ThirdPartyTools></ThirdPartyTools><MitigationControl></MitigationControl><Responsibility></Responsibility><IAControls></IAControls>"

        if ['reference.dc.publisher', 'reference.dc.title', 'reference.dc.subject', 'reference.dc.type', 'reference.dc.identifier'].any? { |a| attributes.key?(a) }
          group.rule.reference = build_rule_reference(attributes)
        end

        group.rule.ident = build_rule_idents(control['cci']) if control['cci']
        group.rule.ident += build_rule_idents(control['legacy']) if control['legacy']

        group.rule.fixtext = HappyMapperTools::Benchmark::Fixtext.new
        group.rule.fixtext.fixref = control['fix_id']
        group.rule.fixtext.fixtext = control['fix']

        group.rule.fix = build_rule_fix(control['fix_id']) if control['fix_id']

        group.rule.check = HappyMapperTools::Benchmark::Check.new
        group.rule.check.system = control['checkref']

        # content_ref is optional for schema compliance
        if attributes['content_ref.name'] || attributes['content_ref.href']
          group.rule.check.content_ref = HappyMapperTools::Benchmark::ContentRef.new
          group.rule.check.content_ref.name = attributes['content_ref.name']
          group.rule.check.content_ref.href = attributes['content_ref.href']
        end

        group.rule.check.content = control['check']

        group_array << group
      end
      @benchmark.group = group_array
    end

    # Construct a Benchmark Testresult from Inspec data. This must be called after all XML processing has occurred for profiles
    # and groups.
    # @param metadata [Hash]
    # @return [TestResult]
    def build_test_results(metadata, data)
      test_result = HappyMapperTools::Benchmark::TestResult.new
      test_result.version = @benchmark.version
      test_result = populate_remark(test_result, data)
      test_result = populate_target_facts(test_result, metadata)
      test_result = populate_identity(test_result, metadata)
      test_result = populate_results(test_result, data)
      populate_score(test_result, @benchmark.group)
    end

    # Contruct a Rule / RuleResult fix element with the provided id.
    def build_rule_fix(fix_id)
      HappyMapperTools::Benchmark::Fix.new.tap { |f| f.id = fix_id }
    end

    # Construct rule identifiers for rule
    # @param idents [Array]
    def build_rule_idents(idents)
      raise "#{idents} is not an Array type." unless idents.is_a?(Array)

      # Each rule identifier is a different element
      idents.map do |identifier|
        HappyMapperTools::Benchmark::Ident.new identifier
      end
    end

    # Contruct a Rule reference element
    def build_rule_reference(attributes)
      reference = HappyMapperTools::Benchmark::ReferenceGroup.new
      reference.dc_publisher = attributes['reference.dc.publisher']
      reference.dc_title = attributes['reference.dc.title']
      reference.dc_subject = attributes['reference.dc.subject']
      reference.dc_type = attributes['reference.dc.type']
      reference.dc_identifier = attributes['reference.dc.identifier']
      reference
    end

    # Create a remark with contextual information about the Inspec version and profiles used
    # @param result [HappyMapperTools::Benchmark::TestResult]
    def populate_remark(result, data)
      result.remark = "Results created using Inspec version #{data['inspec_version']}."
      result.remark += "\n#{data['profiles'].map { |p| "Profile: #{p['name']} Version: #{p['version']}" }.join("\n")}" if data['profiles']
      result
    end

    # Create all target specific information.
    # @param result [HappyMapperTools::Benchmark::TestResult]
    # @param metadata [Hash]
    def populate_target_facts(result, metadata)
      result.target = metadata['fqdn']
      result.target_address = metadata['ip'] if metadata['ip']

      all_facts = []

      if metadata['mac']
        fact = HappyMapperTools::Benchmark::Fact.new
        fact.name = 'urn:xccdf:fact:asset:identifier:mac'
        fact.type = 'string'
        fact.fact = metadata['mac']
        all_facts << fact
      end

      if metadata['ip']
        fact = HappyMapperTools::Benchmark::Fact.new
        fact.name = 'urn:xccdf:fact:asset:identifier:ipv4'
        fact.type = 'string'
        fact.fact = metadata['ip']
        all_facts << fact
      end

      return result unless all_facts.size.nonzero?

      facts = HappyMapperTools::Benchmark::TargetFact.new
      facts.fact = all_facts
      result.target_facts = facts
      result
    end

    # Add information about the the account and organization executing the tests.
    def populate_identity(test_result, metadata)
      if metadata['identity']
        test_result.identity = HappyMapperTools::Benchmark::IdentityType.new
        test_result.identity.authenticated = true
        test_result.identity.identity = metadata['identity']['identity']
        test_result.identity.privileged = metadata['identity']['privileged']
      end

      test_result.organization = metadata['organization'] if metadata['organization']
      test_result
    end

    # Build out the TestResult given all the control and result data.
    def populate_results(test_result, data)
      # NOTE: id is not an XCCDF 1.2 compliant identifier and will need to be updated when that support is added.
      test_result.id = 'result_1'
      test_result.starttime = run_start_time(data)
      test_result.endtime = run_end_time(data)

      # Build out individual results
      all_rule_result = []

      data['controls'].each do |control|
        next if control['results'].nil? || control['results'].empty?

        control_results =
          control['results'].map do |result|
            populate_rule_result(control, result, xccdf_status(result['status'], control['impact']))
          end

        # Consolidate results into single rule result do to lack of multiple=true attribute on Rule.
        # 1. Select the unified result status
        selected_status = control_results.reduce(control_results.first.result) { |f_status, rule_result| xccdf_and_result(f_status, rule_result.result) }

        # 2. Only choose results with that status
        # 3. Combine those results
        all_rule_result << combine_results(control_results.select { |r| r.result == selected_status })
      end

      test_result.rule_result = all_rule_result
      test_result
    end

    # Return the earliest time of execution.
    def run_start_time(data)
      start_times =
        data['controls'].map do |control|
          next if control['results'].nil?

          control['results'].map { |result| DateTime.parse(result['start_time']) }
        end
      start_times.flatten.min
    end

    # Return the latest time of execution accounting for Inspec duration.
    def run_end_time(data)
      end_times =
        data['controls'].map do |control|
          next if control['results'].nil?

          control['results'].map { |result| end_time(result['start_time'], result['run_time']) }
        end
      end_times.flatten.max
    end

    # Create rule-result from the control and Inspec result information
    def populate_rule_result(control, result, result_status)
      rule_result = HappyMapperTools::Benchmark::RuleResultType.new

      rule_result.idref = control['rid']
      rule_result.severity = control['severity']
      rule_result.time = end_time(result['start_time'], result['run_time'])
      rule_result.weight = control['rweight']

      rule_result.result = result_status
      rule_result.message = result_message(result, result_status) if result_message(result, result_status)
      rule_result.instance = result['code_desc']

      rule_result.ident = build_rule_idents(control['cci']) if control['cci']
      rule_result.ident += build_rule_idents(control['legacy']) if control['legacy']

      # Fix information is only necessary when there are failed tests
      rule_result.fix = build_rule_fix(control['fix_id']) if control['fix_id'] && result_status == 'fail'

      rule_result.check = HappyMapperTools::Benchmark::Check.new
      rule_result.check.system = control['checkref']
      rule_result.check.content = result['code_desc']
      rule_result
    end

    # Map the Inspec result status to appropriate XCCDF test result status.
    # XCCDF options include: pass, fail, error, unknown, notapplicable, notchecked, notselected, informational, fixed
    #
    # @param inspec_status [String] The reported Inspec status from an individual test
    # @param impact [String] A value of 0.0 - 1.0
    # @return A valid Inspec status.
    def xccdf_status(inspec_status, impact)
      # Currently, there is no good way to map an Inspec result status to one of XCCDF status unknown or notselected.
      case inspec_status
      when 'failed'
        'fail'
      when 'passed'
        'pass'
      when 'skipped'
        if impact.to_f.zero?
          'notapplicable'
        else
          'notchecked'
        end
      else
        # In the event Inspec adds a new unaccounted for status, mapping to XCCDF unknown.
        'unknown'
      end
    end

    # When more than one result occurs for a rule and the specification does not declare multiple, the result must be combined.
    # This determines the appropriate result to be selected when there are two to compare.
    # @param one [String] A rule-result status
    # @param two [String] A rule-result status
    # @return The result of the AND operation.
    def xccdf_and_result(one, two)
      # From XCCDF specification truth table
      # P = pass
      # F = fail
      # U = unknown
      # E = error
      # N = notapplicable
      # K = notchecked
      # S = notselected
      # I = informational

      case one
      when 'pass'
        %w{fail unknown}.any? { |s| s == two } ? two : one
      when 'fail'
        one
      when 'unknown'
        two == 'fail' ? two : one
      when 'notapplicable'
        %w{pass fail unknown}.any? { |s| s == two } ? two : one
      when 'notchecked'
        %w{pass fail unknown notapplicable}.any? { |s| s == two } ? two : one
      end
    end

    # Combines rule results with the same result into a single rule result.
    def combine_results(rule_results)
      return rule_results.first if rule_results.size == 1

      # Can combine, result, idents (duplicate, take first instance), instance - combine into an array removing duplicates
      # check.content - Only one value allowed, combine by joining with line feed. Prior to, make sure all values are unique.

      rule_result = HappyMapperTools::Benchmark::RuleResultType.new
      rule_result.idref = rule_results.first.idref
      rule_result.severity = rule_results.first.severity
      # Take latest time
      rule_result.time = rule_results.reduce(rule_results.first.time) { |time, r| time > r.time ? time : r.time }
      rule_result.weight = rule_results.first.weight

      rule_result.result = rule_results.first.result
      rule_result.message = rule_results.reduce([]) { |messages, r| r.message ? messages.push(r.message) : messages }
      rule_result.instance = rule_results.reduce([]) { |instances, r| r.instance ? instances.push(r.instance) : instances }.join("\n")

      rule_result.ident = rule_results.first.ident
      rule_result.fix = rule_results.first.fix

      if rule_results.first.check
        rule_result.check = HappyMapperTools::Benchmark::Check.new
        rule_result.check.system = rule_results.first.check.system
        rule_result.check.content = rule_results.map { |r| r.check.content }.join("\n")
      end

      rule_result
    end

    # Calculate an end time given a start time and second duration
    def end_time(start, duration)
      DateTime.parse(start) + (duration / (24*60*60))
    end

    # Builds the message information for rule results
    # @param result [Hash] A single Inspec result
    # @param xccdf_status [String] the xccdf calculated result status for the provided result
    def result_message(result, xccdf_status)
      return unless result['message'] || result['skip_message']

      message = HappyMapperTools::Benchmark::MessageType.new
      # Including the code of the check and the resulting message if there is one.
      message.message = "#{result['code_desc'] ? "#{result['code_desc']}\n\n" : ''}#{result['message'] || result['skip_message']}"
      message.severity = result_message_severity(xccdf_status)
      message
    end

    # All rule-result messages require a defined severity. This determines a value to use based upon the result XCCDF status.
    def result_message_severity(xccdf_status)
      case xccdf_status
      when 'fail'
        'error'
      when 'notapplicable'
        'warning'
      else
        'info'
      end
    end

    # Convert raw Inspec result json into format acceptable for XCCDF transformation.
    def parse_data_for_xccdf(json) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      data = {}

      controls = []
      if json['profiles'].nil?
        controls = json['controls']
      elsif json['profiles'].length == 1
        controls = json['profiles'].last['controls']
      else
        json['profiles'].each do |profile|
          controls.concat(profile['controls'])
        end
      end
      c_data = {}

      controls.each do |control|
        c_id = control['id'].to_sym
        c_data[c_id] = {}
        c_data[c_id]['id']             = control['id']    || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['title']          = control['title'] if control['title'] # Optional attribute
        c_data[c_id]['desc']           = control['desc'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['severity']       = control['tags']['severity'] || 'unknown'
        c_data[c_id]['gid']            = control['tags']['gid'] || control['id']
        c_data[c_id]['gtitle']         = control['tags']['gtitle'] if control['tags']['gtitle'] # Optional attribute
        c_data[c_id]['gdescription']   = control['tags']['gdescription'] if control['tags']['gdescription'] # Optional attribute
        c_data[c_id]['rid']            = control['tags']['rid'] || "r_#{c_data[c_id]['gid']}"
        c_data[c_id]['rversion']       = control['tags']['rversion'] if control['tags']['rversion'] # Optional attribute
        c_data[c_id]['rweight']        = control['tags']['rweight'] if control['tags']['rweight'] # Optional attribute where N/A is not schema compliant
        c_data[c_id]['stig_id']        = control['tags']['stig_id'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['cci']            = control['tags']['cci'] if control['tags']['cci'] # Optional attribute
        c_data[c_id]['legacy']         = control['tags']['legacy'] if control['tags']['legacy'] # Optional attribute
        c_data[c_id]['nist']           = control['tags']['nist'] || ['unmapped']

        # new (post-2020) inspec output places check, fix, and rationale fields in a descriptions block
        if control['descriptions'].is_a?(Hash) && control['descriptions'].key?('check') && control['descriptions'].key?('fix') && control['descriptions'].key?('rationale')
          c_data[c_id]['check']          = control['descriptions']['check'] || DATA_NOT_FOUND_MESSAGE
          c_data[c_id]['fix']            = control['descriptions']['fix'] || DATA_NOT_FOUND_MESSAGE
          c_data[c_id]['rationale']      = control['descriptions']['rationale'] || DATA_NOT_FOUND_MESSAGE
        else
          c_data[c_id]['check']          = control['tags']['check'] || DATA_NOT_FOUND_MESSAGE
          c_data[c_id]['fix']            = control['tags']['fix'] || DATA_NOT_FOUND_MESSAGE
          c_data[c_id]['rationale']      = control['tags']['rationale'] || DATA_NOT_FOUND_MESSAGE
        end
        c_data[c_id]['checkref']       = control['tags']['checkref'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['fix_id']         = control['tags']['fix_id'] if control['tags']['fix_id'] # Optional attribute where N/A is not schema compliant
        c_data[c_id]['cis_family']     = control['tags']['cis_family'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['cis_rid']        = control['tags']['cis_rid'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['cis_level']      = control['tags']['cis_level'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['impact']         = control['impact'].to_s || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['code']           = control['code'].to_s || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['results']        = parse_results_for_xccdf(control['results']) if control['results']
      end

      data['controls'] = c_data.values
      data['profiles'] = parse_profiles_for_xccdf(json['profiles'])
      data['status'] = 'success'
      # If generator exists this is a more up-to-date inspec.json so look for version in the new location, else old location
      data['inspec_version'] = json['generator'].nil? ? json['version'] : json['generator']['version']
      data
    end

    # Set scores for all 4 required/recommended scoring systems.
    def populate_score(test_result, groups)
      score = Utils::XCCDFScore.new(groups, test_result.rule_result)
      test_result.score = [score.default_score, score.flat_score, score.flat_unweighted_score, score.absolute_score]
    end

    # Convert profile information for result processing
    # @param profiles [Array[Hash]] - The profiles section of the JSON output
    def parse_profiles_for_xccdf(profiles)
      return [] unless profiles

      profiles.map do |profile|
        data = {}
        data['name'] = profile['name']
        data['version'] = profile['version']
        data
      end
    end

    # Convert the test result data to a parseable Hash for downstream processing
    # @param results [Array[Hash]] - The results section of the JSON output
    def parse_results_for_xccdf(results)
      results.map do |result|
        data = {}
        data['status'] = result['status']
        data['code_desc'] = result['code_desc']
        data['run_time'] = result['run_time']
        data['start_time'] = result['start_time']
        data['resource'] = result['resource']
        data['message'] = result['message']
        data['skip_message'] = result['skip_message']
        data
      end
    end

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

    def generate_ckl
      vuln_list = []
      @data.keys.each do |control_id|
        vuln_list.push(generate_vuln_data(@data[control_id]))
      end

      si_data_data = @metadata['stigid'] || topmost_profile_name || ''
      si_data_stigid = HappyMapperTools::StigChecklist::SiData.new('stigid', si_data_data)
      si_data_title = HappyMapperTools::StigChecklist::SiData.new('title', si_data_data)

      stig_info = HappyMapperTools::StigChecklist::StigInfo.new([si_data_stigid, si_data_title])

      istig = HappyMapperTools::StigChecklist::IStig.new(stig_info, vuln_list)
      @checklist.stig = HappyMapperTools::StigChecklist::Stigs.new(istig)

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

      vuln.stig_data = stig_data_list.reject(&:nil?)
      vuln.status = Utils::InspecUtil.control_status(control)
      vuln.comments = "\nAutomated compliance tests brought to you by the MITRE corporation and the InSpec project.\n\nInspec Profile: #{control[:profile_name]}\nProfile shasum: #{control[:profile_shasum]}"
      vuln.finding_details = Utils::InspecUtil.control_finding_details(control, vuln.status)
      vuln.severity_override = ''
      vuln.severity_justification = ''

      vuln
    end

    def generate_asset
      asset = HappyMapperTools::StigChecklist::Asset.new
      asset.role = @metadata['role'].nil? ? 'Workstation' : @metadata['role']
      asset.type = @metadata['type'].nil? ? 'Computing' : @metadata['type']
      asset.host_name = generate_hostname
      asset.host_ip = generate_ip
      asset.host_mac = generate_mac
      asset.host_fqdn = generate_fqdn
      asset.tech_area = @metadata['tech_area'].nil? ? '' : @metadata['tech_area']
      asset.target_key = @metadata['target_key'].nil? ? '' : @metadata['target_key']
      asset.web_or_database = @metadata['web_or_database'].nil? ? '0' : @metadata['web_or_database']
      asset.web_db_site = @metadata['web_db_site'].nil? ? '' : @metadata['web_db_site']
      asset.web_db_instance = @metadata['web_db_instance'].nil? ? '' : @metadata['web_db_instance']
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

    def generate_title(title, json, date)
      title ||= "Untitled - Checklist Created from Automated InSpec Results JSON; Profiles: #{json['profiles'].map { |x| x['name'] }.join(' | ')}"
      title + " Checklist Date: #{date || Date.today.to_s}"
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
