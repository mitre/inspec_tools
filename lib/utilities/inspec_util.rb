require 'inspec/objects'
require 'word_wrap'
require 'pp'

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

      controls.each do |control|
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
              data[c_id][:status].push(result['status'])
              data[c_id][:message].push(result['skip_message']) if result['status'] == 'skipped'
              data[c_id][:message].push("FAILED -- Test: #{result['code_desc']}\nMessage: #{result['message']}\n") if result['status'] == 'failed'
              data[c_id][:message].push("PASS -- #{result['code_desc']}\n") if result['status'] == 'passed'
            end
          end
          if data[c_id][:impact].to_f.zero?
            data[c_id][:message] = control['desc']
          end
        end
      end
      data
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

    def self.unpack_inspec_json(directory, inspec_json, separated, output_format)
      controls = generate_controls(inspec_json)
      unpack_profile(directory || 'profile', controls, separated, output_format || 'json')
      create_inspec_yml(directory || 'profile', inspec_json)
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
        else
          control.desc = json_control['desc']
        end
        control.id     = json_control['id']
        control.title  = json_control['title']
        control.impact = get_impact(json_control['impact'])
        control.add_tag(Inspec::Tag.new('gtitle', json_control['tags']['gtitle']))
        control.add_tag(Inspec::Tag.new('satisfies', json_control['tags']['satisfies'])) if json_control['tags']['satisfies']
        control.add_tag(Inspec::Tag.new('gid',      json_control['tags']['gid']))
        control.add_tag(Inspec::Tag.new('rid',      json_control['tags']['rid']))
        control.add_tag(Inspec::Tag.new('stig_id',  json_control['tags']['stig_id']))
        control.add_tag(Inspec::Tag.new('fix_id', json_control['tags']['fix_id']))
        control.add_tag(Inspec::Tag.new('cci', json_control['tags']['cci']))
        control.add_tag(Inspec::Tag.new('nist', json_control['tags']['nist']))
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
        control.add_tag(Inspec::Tag.new('check', json_control['tags']['check']))
        control.add_tag(Inspec::Tag.new('fix', json_control['tags']['fix']))

        controls << control
      end
      controls
    end

    # @!method print_benchmark_info(info)
    # writes benchmark info to profile inspec.yml file
    #
    private_class_method def self.create_inspec_yml(directory, inspec_json)
      benchmark_info =
"name: #{inspec_json['name']}
title: #{inspec_json['title']}
maintainer: #{inspec_json['maintainer']}
copyright: #{inspec_json['copyright']}
copyright_email: #{inspec_json['copyright_email']}
license: #{inspec_json['license']}
summary: #{inspec_json['summary']}
version: #{inspec_json['version']}"

      myfile = File.new("#{directory}/inspec.yml", 'w')
      myfile.puts benchmark_info
    end

    private_class_method def self.unpack_profile(directory, controls, separated, output_format)
      FileUtils.rm_rf(directory) if Dir.exist?(directory)
      Dir.mkdir directory unless Dir.exist?(directory)
      Dir.mkdir "#{directory}/controls" unless Dir.exist?("#{directory}/controls")
      Dir.mkdir "#{directory}/libraries" unless Dir.exist?("#{directory}/libraries")
      myfile = File.new("#{directory}/README.md", 'w')
      myfile.puts "# Example InSpec Profile\n\nthis example shows the implementation of an InSpec profile."
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
