require_relative 'xccdf_score'

module InspecTools
  # Data conversions for Inspec output into XCCDF format.
  class ToXCCDF # rubocop:disable Metrics/ClassLength
    # @param attribute [Hash] XCCDF supplemental attributes
    # @param data [Hash] Converted Inspec output data
    def initialize(attribute, data)
      @attribute = attribute
      @data = data
    end

    # Construct a Benchmark Testresult from Inspec data. This must be called after all XML processing has occurred for profiles
    # and groups.
    # @param benchmark [Hash]
    # @param metadata [Hash]
    # @return [TestResult]
    def build_test_results(benchmark, metadata)
      test_result = HappyMapperTools::Benchmark::TestResult.new
      test_result.version = benchmark.version
      populate_remark(test_result)
      populate_target_facts(test_result, metadata)
      populate_identity(test_result, metadata)
      populate_results(test_result)
      populate_score(test_result, benchmark.group)

      test_result
    end

    # Construct rule identifiers for rule
    # @param idents [Array]
    def build_rule_idents(idents)
      raise "#{idents} is not an Array type." unless idents.is_a?(Array)

      # Each rule identifier is a different element
      idents.map do |identifier|
        ident = HappyMapperTools::Benchmark::Ident.new
        ident.system = 'https://public.cyber.mil/stigs/cci/'
        ident.ident = identifier
        ident
      end
    end

    # Contruct a Rule / RuleResult fix element with the provided id.
    def build_rule_fix(fix_id)
      HappyMapperTools::Benchmark::Fix.new.tap { |f| f.id = fix_id }
    end

    # Contruct a Rule reference element
    def build_rule_reference
      reference = HappyMapperTools::Benchmark::ReferenceGroup.new
      reference.dc_publisher = @attribute['reference.dc.publisher']
      reference.dc_title = @attribute['reference.dc.title']
      reference.dc_subject = @attribute['reference.dc.subject']
      reference.dc_type = @attribute['reference.dc.type']
      reference.dc_identifier = @attribute['reference.dc.identifier']
      reference
    end

    private

    # Create a remark with contextual information about the Inspec version and profiles used
    # @param result [HappyMapperTools::Benchmark::TestResult]
    def populate_remark(result)
      result.remark = "Results created using Inspec version #{@data['inspec_version']}.\n#{@data['profiles'].map { |p| "Profile: #{p['name']} Version: #{p['version']}" }.join("\n")}"
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

      return unless all_facts.size.nonzero?

      facts = HappyMapperTools::Benchmark::TargetFact.new
      facts.fact = all_facts
      result.target_facts = facts
    end

    # Build out the TestResult given all the control and result data.
    def populate_results(test_result)
      # Note: id is not an XCCDF 1.2 compliant identifier and will need to be updated when that support is added.
      test_result.id = 'result_1'
      test_result.starttime = run_start_time
      test_result.endtime = run_end_time

      # Build out individual results
      all_rule_result = []

      @data['controls'].each do |control|
        next if control['results'].empty?

        control_results =
          control['results'].map do |result|
            populate_rule_result(control, result, xccdf_status(result['status'], control['impact']))
          end

        # Consolidate results into single rule result do to lack of multiple=true attribute on Rule.
        # 1. Select the unified result status
        selected_status = control_results.reduce(control_results.first.result) { |f_status, rule_result| xccdf_and_result(f_status, rule_result) }

        # 2. Only choose results with that status
        # 3. Combine those results
        all_rule_result << combine_results(control_results.select { |r| r.result == selected_status })
      end

      test_result.rule_result = all_rule_result
      test_result
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

      # Fix information is only necessary when there are failed tests
      rule_result.fix = build_rule_fix(control['fix_id']) if control['fix_id'] && result_status == 'fail'

      rule_result.check = HappyMapperTools::Benchmark::Check.new
      rule_result.check.system = control['checkref']
      rule_result.check.content = result['code_desc']
      rule_result
    end

    # Combines rule results with the same result into a single rule result.
    def combine_results(rule_results) # rubocop:disable Metrics/AbcSize
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

    # Add information about the the account and organization executing the tests.
    def populate_identity(test_result, metadata)
      if metadata['identity']
        test_result.identity = HappyMapperTools::Benchmark::IdentityType.new
        test_result.identity.authenticated = true
        test_result.identity.identity = metadata['identity']['identity']
        test_result.identity.privileged = metadata['identity']['privileged']
      end

      test_result.organization = metadata['organization'] if metadata['organization']
    end

    # Return the earliest time of execution.
    def run_start_time
      @data['controls'].map { |control| control['results'].map { |result| DateTime.parse(result['start_time']) } }.flatten.min
    end

    # Return the latest time of execution accounting for Inspec duration.
    def run_end_time
      end_times =
        @data['controls'].map do |control|
          control['results'].map { |result| end_time(result['start_time'], result['run_time']) }
        end

      end_times.flatten.max
    end

    # Calculate an end time given a start time and second duration
    def end_time(start, duration)
      DateTime.parse(start) + (duration / (24*60*60))
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
    def xccdf_and_result(one, two) # rubocop:disable Metrics/CyclomaticComplexity
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

    # Builds the message information for rule results
    # @param result [Hash] A single Inspec result
    # @param xccdf_status [String] the xccdf calculated result status for the provided result
    def result_message(result, xccdf_status)
      return unless result['message'] || result['skip_message']

      message = HappyMapperTools::Benchmark::MessageType.new
      # Including the code of the check and the resulting message if there is one.
      message.message = "#{result['code_desc'] ? result['code_desc'] + "\n\n" : ''}#{result['message'] || result['skip_message']}"
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

    # Set scores for all 4 required/recommended scoring systems.
    def populate_score(test_result, groups)
      score = InspecTools::XCCDFScore.new(groups, test_result.rule_result)
      test_result.score = [score.default_score, score.flat_score, score.flat_unweighted_score, score.absolute_score]
    end
  end
end
