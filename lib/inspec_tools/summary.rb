require 'json'
require 'yaml'
require_relative '../utilities/inspec_util'

# Impact Definitions
CRITICAL = 0.9
HIGH = 0.7
MEDIUM = 0.5
LOW = 0.3

BUCKETS = %i(failed passed no_impact skipped error).freeze
TALLYS = %i(total critical high medium low).freeze

THRESHOLD_TEMPLATE = File.expand_path('../data/threshold.yaml', File.dirname(__FILE__))

module InspecTools
  # rubocop:disable Metrics/ClassLength
  class Summary
    attr_reader :json
    attr_reader :json_full
    attr_reader :json_counts
    attr_reader :threshold_file
    attr_reader :threshold_inline
    attr_reader :summary

    def initialize(**options)
      options = options[:options]
      @json = JSON.parse(File.read(options[:inspec_json]))
      @json_full = false || options[:json_full]
      @json_counts = false || options[:json_counts]
      @threshold_file = options[:threshold_file].nil? ? nil : Utils::InspecUtil.to_dotted_hash(YAML.load_file(options[:threshold_file]))
      @threshold_inline = options[:threshold_inline].nil? ? nil : Utils::InspecUtil.to_dotted_hash(YAML.safe_load(options[:threshold_inline]))
      @summary = compute_summary
    end

    def output_summary
      unless @json_full || @json_counts
        output_threshold_compliance_level
        puts "\nOverall compliance: #{@summary[:compliance]}%\n\n"
        @summary[:status].keys.each do |category|
          puts category
          @summary[:status][category].keys.each do |impact|
            puts "\t#{impact} : #{@summary[:status][category][impact]}"
          end
        end
      end

      puts @summary.to_json if @json_full
      puts @summary[:status].to_json if @json_counts
    end

    def threshold
      @threshold = Utils::InspecUtil.to_dotted_hash(YAML.load_file(THRESHOLD_TEMPLATE))
      @threshold.merge!(select_given_threshold)
      threshold_compliance
    end

    private

    def output_threshold_compliance_level
      if @threshold_inline
        puts "\nThreshold compliance: #{@threshold_inline['compliance.min']}%"
      elsif @threshold_file
        puts "\nThreshold compliance: #{@threshold_file['compliance.min']}%"
      end
    end

    def select_given_threshold
      raise 'Please provide threshold as a yaml file or inline yaml' if !@threshold_file && !@threshold_inline

      return @threshold_inline if @threshold_inline

      @threshold_file
    end

    # rubocop:disable Metrics/AbcSize
    def compute_summary
      data = Utils::InspecUtil.parse_data_for_ckl(@json)

      data.keys.each do |control_id|
        current_control = data[control_id]
        current_control[:compliance_status] = Utils::InspecUtil.control_status(current_control, true)
        current_control[:finding_details] = Utils::InspecUtil.control_finding_details(current_control, current_control[:compliance_status])
      end

      summary = {}
      summary[:buckets] = {}
      summary[:buckets][:failed]    = select_by_status(data, 'Open')
      summary[:buckets][:passed]    = select_by_status(data, 'NotAFinding')
      summary[:buckets][:no_impact] = select_by_status(data, 'Not_Applicable')
      summary[:buckets][:skipped]   = select_by_status(data, 'Not_Reviewed')
      summary[:buckets][:error]     = select_by_status(data, 'Profile_Error')

      summary[:status] = {}
      summary[:status][:failed]    = tally_by_impact(summary[:buckets][:failed])
      summary[:status][:passed]    = tally_by_impact(summary[:buckets][:passed])
      summary[:status][:no_impact] = tally_by_impact(summary[:buckets][:no_impact])
      summary[:status][:skipped]   = tally_by_impact(summary[:buckets][:skipped])
      summary[:status][:error]     = tally_by_impact(summary[:buckets][:error])

      summary[:compliance] = compute_compliance(summary)
      summary
    end
    # rubocop:enable Metrics/AbcSize

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

    def compute_compliance(summary)
      (summary[:status][:passed][:total]*100.0/
        (summary[:status][:passed][:total]+
         summary[:status][:failed][:total]+
         summary[:status][:skipped][:total]+
         summary[:status][:error][:total])).floor
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/CyclomaticComplexity
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
      puts "Compliance threshold of #{@threshold['compliance.min']}\% met. Current compliance at #{@summary[:compliance]}\%" if compliance
      compliance
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/CyclomaticComplexity
  end
  # rubocop:enable Metrics/ClassLength
end
