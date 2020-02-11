require 'inspec/objects'
require 'inspec/impact'
require 'word_wrap'
require 'pp'
require 'uri'
require 'net/http'
require 'fileutils'

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/MethodLength

module Utils
  class InspecUtil
    DATA_NOT_FOUND_MESSAGE = 'N/A'.freeze
    WIDTH = 80

    def self.parse_data_for_xccdf(json)
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

      controls.each do |control| # rubocop:disable Metrics/BlockLength
        c_id = control['id'].to_sym
        c_data[c_id] = {}
        c_data[c_id]['id']             = control['id']    || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['title']          = control['title'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['desc']           = control['desc'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['severity']       = control['tags']['severity'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['gid']            = control['tags']['gid'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['gtitle']         = control['tags']['gtitle'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['gdescription']   = control['tags']['gdescription'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['rid']            = control['tags']['rid'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['rversion']       = control['tags']['rversion'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['rweight']        = control['tags']['rweight'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['stig_id']        = control['tags']['stig_id'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['cci']            = control['tags']['cci'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['nist']           = control['tags']['nist'] || ['unmapped']
        c_data[c_id]['check']          = control['tags']['check'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['checkref']       = control['tags']['checkref'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['fix']            = control['tags']['fix'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['fixref']         = control['tags']['fixref'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['fix_id']         = control['tags']['fix_id'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['rationale']      = control['tags']['rationale'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['cis_family']     = control['tags']['cis_family'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['cis_rid']        = control['tags']['cis_rid'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['cis_level']      = control['tags']['cis_level'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['impact']         = control['impact'].to_s || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['code']           = control['code'].to_s || DATA_NOT_FOUND_MESSAGE
      end

      data['controls'] = c_data.values
      data['status'] = 'success'
      data
    end

    def self.parse_data_for_ckl(json)
      data = {}

      # Parse for inspec profile results json
      json['profiles'].each do |profile|
        profile['controls'].each do |control|
          c_id = control['id'].to_sym
          data[c_id] = {}
          data[c_id][:vuln_num]       = control['id'] unless control['id'].nil?
          data[c_id][:rule_title]     = control['title'] unless control['title'].nil?
          data[c_id][:vuln_discuss]   = control['desc'] unless control['desc'].nil?
          unless control['tags'].nil?
            data[c_id][:severity]       = control['tags']['severity'] unless control['tags']['severity'].nil?
            data[c_id][:gid]            = control['tags']['gid'] unless control['tags']['gid'].nil?
            data[c_id][:group_title]    = control['tags']['gtitle'] unless control['tags']['gtitle'].nil?
            data[c_id][:rule_id]        = control['tags']['rid'] unless control['tags']['rid'].nil?
            data[c_id][:rule_ver]       = control['tags']['stig_id'] unless control['tags']['stig_id'].nil?
            data[c_id][:cci_ref]        = control['tags']['cci'] unless control['tags']['cci'].nil?
            data[c_id][:nist]           = control['tags']['nist'].join(' ') unless control['tags']['nist'].nil?
            data[c_id][:check_content]  = control['tags']['check'] unless control['tags']['check'].nil?
            data[c_id][:fix_text]       = control['tags']['fix'] unless control['tags']['fix'].nil?
          end
          data[c_id][:impact]         = control['impact'].to_s unless control['impact'].nil?
          data[c_id][:profile_name]   = profile['name'].to_s unless profile['name'].nil?
          data[c_id][:profile_shasum] = profile['sha256'].to_s unless profile['sha256'].nil?

          data[c_id][:status] = []
          data[c_id][:message] = []
          if control.key?('results')
            control['results'].each do |result|
              if !result['backtrace'].nil?
                result['status'] = 'error'
              end
              data[c_id][:status].push(result['status'])
              data[c_id][:message].push("SKIPPED -- Test: #{result['code_desc']}\nMessage: #{result['skip_message']}\n") if result['status'] == 'skipped'
              data[c_id][:message].push("FAILED -- Test: #{result['code_desc']}\nMessage: #{result['message']}\n") if result['status'] == 'failed'
              data[c_id][:message].push("PASS -- #{result['code_desc']}\n") if result['status'] == 'passed'
              data[c_id][:message].push("PROFILE_ERROR -- Test: #{result['code_desc']}\nMessage: #{result['backtrace']}\n") if result['status'] == 'error'
            end
          end
          if data[c_id][:impact].to_f.zero?
            data[c_id][:message].unshift("NOT_APPLICABLE -- Description: #{control['desc']}\n\n")
          end
        end
      end
      data
    end

    def self.get_platform(json)
      json['profiles'].find { |profile| !profile[:platform].nil? }
    end

    def self.to_dotted_hash(hash, recursive_key = '')
      hash.each_with_object({}) do |(k, v), ret|
        key = recursive_key + k.to_s
        if v.is_a? Hash
          ret.merge! to_dotted_hash(v, key + '.')
        else
          ret[key] = v
        end
      end
    end

    def self.control_status(control)
      status_list = control[:status].uniq
      if status_list.include?('error')
        result = 'Profile_Error'
      elsif control[:impact].to_f.zero?
        result = 'Not_Applicable'
      elsif status_list.include?('failed')
        result = 'Open'
      elsif status_list.include?('passed')
        result = 'NotAFinding'
      elsif status_list.include?('skipped')
        result = 'Not_Reviewed'
      else
        result = 'Profile_Error'
      end
      result
    end

    def self.control_finding_details(control, control_clk_status)
      result = "One or more of the automated tests failed or was inconclusive for the control \n\n #{control[:message].sort.join}" if control_clk_status == 'Open'
      result = "All Automated tests passed for the control \n\n #{control[:message].join}" if control_clk_status == 'NotAFinding'
      result = "Automated test skipped due to known accepted condition in the control : \n\n#{control[:message].join}" if control_clk_status == 'Not_Reviewed'
      result = "Justification: \n #{control[:message].join}" if control_clk_status == 'Not_Applicable'
      result = 'No test available or some test errors occurred for this control' if control_clk_status == 'Profile_Error'
      result
    end

    # @!method get_impact(severity)
    #   Takes in the STIG severity tag and converts it to the InSpec #{impact}
    #   control tag.
    #   At the moment the mapping is static, so that:
    #     high => 0.7
    #     medium => 0.5
    #     low => 0.3
    # @param severity [String] the string value you want to map to an InSpec
    # 'impact' level.
    #
    # @return impact [Float] the impact level level mapped to the XCCDF severity
    # mapped to a float between 0.0 - 1.0.
    #
    # @todo Allow for the user to pass in a hash for the desired mapping of text
    # values to numbers or to override our hard coded values.
    #
    def self.get_impact(severity)
      case severity
      when 'low' then 0.3
      when 'medium' then 0.5
      when 'high' then 0.7
      else severity
      end
    end

    def self.get_impact_string(impact)
      Inspec::Impact.string_from_impact(impact) unless impact.nil?
    end

    def self.unpack_inspec_json(directory, inspec_json, separated, output_format)
      if directory == 'id'
        directory = inspec_json['name']
      end
      controls = generate_controls(inspec_json)
      unpack_profile(directory || 'profile', controls, separated, output_format || 'json')
      create_inspec_yml(directory || 'profile', inspec_json)
      create_license(directory || 'profile', inspec_json)
      create_readme_md(directory || 'profile', inspec_json)
    end

    private_class_method def self.wrap(str, width = WIDTH)
      str.gsub!("desc  \"\n    ", 'desc  "')
      str.gsub!(/\\r/, "\n")
      str.gsub!(/\\n/, "\n")

      WordWrap.ww(str.to_s, width)
    end

    private_class_method def self.generate_controls(inspec_json)
      controls = []
      inspec_json['controls'].each do |json_control|
        control = Inspec::Control.new
        if (defined? control.desc).nil?
          control.descriptions[:default] = json_control['desc']
          control.descriptions[:rationale] = json_control['tags']['rationale']
          control.descriptions[:check] = json_control['tags']['check']
          control.descriptions[:fix] = json_control['tags']['fix']
        else
          control.desc = json_control['desc']
        end
        control.id     = json_control['id']
        control.title  = json_control['title']
        control.impact = get_impact(json_control['impact'])
        control.add_tag(Inspec::Tag.new('severity', json_control['tags']['severity']))
        control.add_tag(Inspec::Tag.new('gtitle', json_control['tags']['gtitle']))
        control.add_tag(Inspec::Tag.new('satisfies', json_control['tags']['satisfies'])) if json_control['tags']['satisfies']
        control.add_tag(Inspec::Tag.new('gid',      json_control['tags']['gid']))
        control.add_tag(Inspec::Tag.new('rid',      json_control['tags']['rid']))
        control.add_tag(Inspec::Tag.new('stig_id',  json_control['tags']['stig_id']))
        control.add_tag(Inspec::Tag.new('fix_id', json_control['tags']['fix_id']))
        control.add_tag(Inspec::Tag.new('cci', json_control['tags']['cci']))
        control.add_tag(Inspec::Tag.new('nist', json_control['tags']['nist']))
        control.add_tag(Inspec::Tag.new('cis_level', json_control['tags']['cis_level'])) unless json_control['tags']['cis_level'].nil?
        control.add_tag(Inspec::Tag.new('cis_controls', json_control['tags']['cis_controls'])) unless json_control['tags']['cis_controls'].nil?
        control.add_tag(Inspec::Tag.new('cis_rid', json_control['tags']['cis_rid'])) unless json_control['tags']['cis_rid'].nil?
        control.add_tag(Inspec::Tag.new('ref', json_control['tags']['ref'])) unless json_control['tags']['ref'].nil?
        control.add_tag(Inspec::Tag.new('false_negatives', json_control['tags']['false_negatives'])) if json_control['tags']['false_positives'] != ''
        control.add_tag(Inspec::Tag.new('false_positives', json_control['tags']['false_positives'])) if json_control['tags']['false_positives'] != ''
        control.add_tag(Inspec::Tag.new('documentable', json_control['tags']['documentable'])) if json_control['tags']['documentable'] != ''
        control.add_tag(Inspec::Tag.new('mitigations', json_control['tags']['mitigations'])) if json_control['tags']['mitigations'] != ''
        control.add_tag(Inspec::Tag.new('severity_override_guidance', json_control['tags']['documentable'])) if json_control['tags']['severity_override_guidance'] != ''
        control.add_tag(Inspec::Tag.new('potential_impacts', json_control['tags']['potential_impacts'])) if json_control['tags']['potential_impacts'] != ''
        control.add_tag(Inspec::Tag.new('third_party_tools', json_control['tags']['third_party_tools'])) if json_control['tags']['third_party_tools'] != ''
        control.add_tag(Inspec::Tag.new('mitigation_controls', json_control['tags']['mitigation_controls'])) if json_control['tags']['mitigation_controls'] != ''
        control.add_tag(Inspec::Tag.new('responsibility', json_control['tags']['responsibility'])) if json_control['tags']['responsibility'] != ''
        control.add_tag(Inspec::Tag.new('ia_controls', json_control['tags']['ia_controls'])) if json_control['tags']['ia_controls'] != ''

        controls << control
      end
      controls
    end

    # @!method print_benchmark_info(info)
    # writes benchmark info to profile inspec.yml file
    #
    private_class_method def self.create_inspec_yml(directory, inspec_json)
      benchmark_info =
        "name: #{inspec_json['name']}\n" \
        "title: #{inspec_json['title']}\n" \
        "maintainer: #{inspec_json['maintainer']}\n" \
        "copyright: #{inspec_json['copyright']}\n" \
        "copyright_email: #{inspec_json['copyright_email']}\n" \
        "license: #{inspec_json['license']}\n" \
        "summary: #{inspec_json['summary']}\n" \
        "version: #{inspec_json['version']}\n"

      myfile = File.new("#{directory}/inspec.yml", 'w')
      myfile.puts benchmark_info
    end

    private_class_method def self.create_license(directory, inspec_json)
      license_content = ''
      if !inspec_json['license'].nil?
        begin
          response = Net::HTTP.get_response(URI(inspec_json['license']))
          if response.code == '200'
            license_content = response.body
          else
            license_content = inspec_json['license']
          end
        rescue StandardError => e
          license_content = inspec_json['license']
        end
      end

      myfile = File.new("#{directory}/LICENSE", 'w')
      myfile.puts license_content
    end

    private_class_method def self.create_readme_md(directory, inspec_json)
      readme_contents =
        "\# #{inspec_json['title']}\n" \
        "#{inspec_json['summary']}\n" \
        "---\n" \
        "Name: #{inspec_json['name']}\n" \
        "Author: #{inspec_json['maintainer']}\n" \
        "Status: #{inspec_json['status']}\n" \
        "Copyright: #{inspec_json['copyright']}\n" \
        "Copyright Email: #{inspec_json['copyright_email']}\n" \
        "Version: #{inspec_json['version']}\n" \
        "#{inspec_json['plaintext']}\n" \
        "Reference: #{inspec_json['reference_href']}\n" \
        "Reference by: #{inspec_json['reference_publisher']}\n" \
        "Reference source: #{inspec_json['reference_source']}\n"

      myfile = File.new("#{directory}/README.md", 'w')
      myfile.puts readme_contents
    end

    private_class_method def self.unpack_profile(directory, controls, separated, output_format)
      FileUtils.rm_rf(directory) if Dir.exist?(directory)
      Dir.mkdir directory unless Dir.exist?(directory)
      Dir.mkdir "#{directory}/controls" unless Dir.exist?("#{directory}/controls")
      Dir.mkdir "#{directory}/libraries" unless Dir.exist?("#{directory}/libraries")
      if separated
        if output_format == 'ruby'
          controls.each do |control|
            file_name = control.id.to_s
            myfile = File.new("#{directory}/controls/#{file_name}.rb", 'w')
            myfile.puts wrap(control.to_ruby, WIDTH) + "\n"
            myfile.close
          end
        else
          controls.each do |control|
            file_name = control.id.to_s
            myfile = File.new("#{directory}/controls/#{file_name}.rb", 'w')
            PP.pp(control.to_hash, myfile)
            myfile.close
          end
        end
      else
        myfile = File.new("#{directory}/controls/controls.rb", 'w')
        if output_format == 'ruby'
          controls.each do |control|
            myfile.puts wrap(control.to_ruby, WIDTH) + "\n"
          end
        else
          controls.each do |control|
            if (defined? control.desc).nil?
              control.descriptions[:default].strip!
            else
              control.desc.strip!
            end

            PP.pp(control.to_hash, myfile)
          end
        end
        myfile.close
      end
    end
  end
end
