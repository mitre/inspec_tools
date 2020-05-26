require 'json'
require 'yaml'
require_relative '../utilities/inspec_util'

# rubocop:disable Metrics/AbcSize

# Impact Definitions
CRITICAL = 0.9
HIGH = 0.7
MEDIUM = 0.5
LOW = 0.3

BUCKETS = %i{failed passed no_impact skipped error}.freeze
TALLYS = %i{total critical high medium low}.freeze

THRESHOLD_TEMPLATE = File.expand_path('../data/threshold.yaml', File.dirname(__FILE__))

module InspecTools
  class Summary
    def initialize(inspec_json)
      @json = JSON.parse(inspec_json)
    end

    def to_summary
      @data = Utils::InspecUtil.parse_data_for_ckl(@json)
      @summary = {}
      @data.keys.each do |control_id|
        current_control = @data[control_id]
        current_control[:compliance_status] = Utils::InspecUtil.control_status(current_control, true)
        current_control[:finding_details] = Utils::InspecUtil.control_finding_details(current_control, current_control[:compliance_status])
      end
      compute_summary
      @summary
    end

    def threshold(threshold = nil)
      @summary = to_summary
      @threshold = Utils::InspecUtil.to_dotted_hash(YAML.load_file(THRESHOLD_TEMPLATE))
      parse_threshold(Utils::InspecUtil.to_dotted_hash(threshold))
      threshold_compliance
    end

    private

    def compute_summary
      @summary[:buckets] = {}
      @summary[:buckets][:failed]    = select_by_status(@data, 'Open')
      @summary[:buckets][:passed]    = select_by_status(@data, 'NotAFinding')
      @summary[:buckets][:no_impact] = select_by_status(@data, 'Not_Applicable')
      @summary[:buckets][:skipped]   = select_by_status(@data, 'Not_Reviewed')
      @summary[:buckets][:error]     = select_by_status(@data, 'Profile_Error')

      @summary[:status] = {}
      @summary[:status][:failed]    = tally_by_impact(@summary[:buckets][:failed])
      @summary[:status][:passed]    = tally_by_impact(@summary[:buckets][:passed])
      @summary[:status][:no_impact] = tally_by_impact(@summary[:buckets][:no_impact])
      @summary[:status][:skipped]   = tally_by_impact(@summary[:buckets][:skipped])
      @summary[:status][:error]     = tally_by_impact(@summary[:buckets][:error])

      @summary[:compliance] = compute_compliance
    end

    def select_by_impact(controls, impact)
      controls.select { |_key, value| value[:impact].to_f.eql?(impact) }
    end

    def select_by_status(controls, status)
      controls.select { |_key, value| value[:compliance_status].eql?(status) }
    end

    def tally_by_impact(controls)
      tally = {}
      tally[:total]    = controls.count
      tally[:critical] = select_by_impact(controls, CRITICAL).count
      tally[:high]     = select_by_impact(controls, HIGH).count
      tally[:medium]   = select_by_impact(controls, MEDIUM).count
      tally[:low]      = select_by_impact(controls, LOW).count
      tally
    end

    def compute_compliance
      (@summary[:status][:passed][:total]*100.0/
        (@summary[:status][:passed][:total]+
         @summary[:status][:failed][:total]+
         @summary[:status][:skipped][:total]+
         @summary[:status][:error][:total])).round(1)
    end

    def threshold_compliance
      compliance = true
      failure = []
      max = @threshold['compliance.max']
      min = @threshold['compliance.min']
      if max != -1 and @summary[:compliance] > max
        compliance = false
        failure << "Expected compliance.max:#{max} got:#{@summary[:compliance]}"
      end
      if min != -1 and @summary[:compliance] < min
        compliance = false
        failure << "Expected compliance.min:#{min} got:#{@summary[:compliance]}"
      end
      status = @summary[:status]
      BUCKETS.each do |bucket|
        TALLYS.each do |tally|
          max = @threshold["#{bucket}.#{tally}.max"]
          min = @threshold["#{bucket}.#{tally}.min"]
          if max != -1 and status[bucket][tally] > max
            compliance = false
            failure << "Expected #{bucket}.#{tally}.max:#{max} got:#{status[bucket][tally]}"
          end
          if min != -1 and status[bucket][tally] < min
            compliance = false
            failure << "Expected #{bucket}.#{tally}.min:#{min} got:#{status[bucket][tally]}"
          end
        end
      end
      puts failure.join("\n") unless compliance
      puts 'Compliance threshold met' if compliance
      compliance
    end

    def parse_threshold(new_threshold)
      @threshold.merge!(new_threshold)
    end
  end
end
