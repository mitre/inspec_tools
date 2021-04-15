module Utils
  # Data transformation from Inspec result output into usable data for XCCDF conversions.
  class FromInspec
    DATA_NOT_FOUND_MESSAGE = 'N/A'.freeze

    # Convert raw Inspec result json into format acceptable for XCCDF transformation.
    def parse_data_for_xccdf(json)
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
        if control.key?('descriptions')
          desc = control['descriptions']
          c_data[c_id]['check']          = desc['check'] || DATA_NOT_FOUND_MESSAGE
          c_data[c_id]['fix']            = desc['fix'] || DATA_NOT_FOUND_MESSAGE
          c_data[c_id]['rationale']      = desc['rationale'] || DATA_NOT_FOUND_MESSAGE
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
      data['inspec_version'] = json['version']
      data
    end

    private

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
  end
end
