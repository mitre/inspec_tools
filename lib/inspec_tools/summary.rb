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
    attr_reader :threshold

    def initialize(**options)
      options = options[:options]
      @json = JSON.parse(File.read(options[:inspec_json]))
      @json_full = false || options[:json_full]
      @json_counts = false || options[:json_counts]
      @threshold = parse_threshold(options[:threshold_inline], options[:threshold_file])
      @threshold_provided = options[:threshold_inline] || options[:threshold_file]
      @summary = compute_summary
    end

    def output_summary
      unless @json_full || @json_counts
        puts "\nThreshold compliance: #{@threshold['compliance.min']}%"
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

    def results_meet_threshold?
      raise 'Please provide threshold as a yaml file or inline yaml' unless @threshold_provided

      compliance = true
      failure = []
      failure << check_max_compliance(@threshold['compliance.max'], @summary[:compliance], '', 'compliance')
      failure << check_min_compliance(@threshold['compliance.min'], @summary[:compliance], '', 'compliance')

      BUCKETS.each do |bucket|
        TALLYS.each do |tally|
          failure << check_min_compliance(@threshold["#{bucket}.#{tally}.min"], @summary[:status][bucket][tally], bucket, tally)
          failure << check_max_compliance(@threshold["#{bucket}.#{tally}.max"], @summary[:status][bucket][tally], bucket, tally)
        end
      end

      failure.reject!(&:nil?)
      compliance = false if failure.length.positive?
      output(compliance, failure)
      compliance
    end

    private

    def check_min_compliance(min, data, bucket, tally)
      expected_to_string(bucket, tally, 'min', min, data) if min != -1 and data < min
    end

    def check_max_compliance(max, data, bucket, tally)
      expected_to_string(bucket, tally, 'max', max, data) if max != -1 and data > max
    end

    def output(passed_threshold, what_failed)
      if passed_threshold
        puts "Overall compliance threshold of #{@threshold['compliance.min']}\% met. Current compliance at #{@summary[:compliance]}\%"
      else
        puts 'Compliance threshold was not met: '
        puts what_failed.join("\n")
      end
    end

    def expected_to_string(bucket, tally, maxmin, value, got)
      return "Expected #{bucket}.#{tally}.#{maxmin}:#{value} got:#{got}" unless bucket.empty? || bucket.nil?

      "Expected #{tally}.#{maxmin}:#{value}\% got:#{got}\%"
    end

    def parse_threshold(threshold_inline, threshold_file)
      threshold = Utils::InspecUtil.to_dotted_hash(YAML.load_file(THRESHOLD_TEMPLATE))
      threshold.merge!(Utils::InspecUtil.to_dotted_hash(YAML.load_file(threshold_file))) if threshold_file
      threshold.merge!(Utils::InspecUtil.to_dotted_hash(YAML.safe_load(threshold_inline))) if threshold_inline
      threshold
    end

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
      %i(failed passed no_impact skipped error).each do |key|
        summary[:status][key] = tally_by_impact(summary[:buckets][key])
      end
      summary[:compliance] = compute_compliance(summary)
      summary
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

    def compute_compliance(summary)
      (summary[:status][:passed][:total]*100.0/
        (summary[:status][:passed][:total]+
         summary[:status][:failed][:total]+
         summary[:status][:skipped][:total]+
         summary[:status][:error][:total])).floor
    end
  end
  # rubocop:enable Metrics/ClassLength
end
