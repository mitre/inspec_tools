#!/usr/bin/env ruby
# encoding: utf-8
# author: Rony Xavier rx294@nyu.edu

# Parses and extracts inspec controls from both inspec profile json inspec results json.
# If the json contains an overlay profile all the controls on the within the profiles are 
# concatenated

require 'json'

DATA_NOT_FOUND_MESSAGE = 'N/A'

module InspecTo
  class InspecProfileParser
    def initialize(inspec_json)
      begin
        @data = Hash.new
        parse_json(inspec_json)
        @data['status'] = 'success'
      rescue => err
        puts "Exception: #{err}"
        @data['status'] = "Exception: #{err}"
      end
    end
  
    def content
      @data
    end
  
    def parse_json(json)
      file = JSON.parse(json)
      controls = []
      if file['profiles'].nil?
        controls = file['controls']
      elsif file['profiles'].length == 1
        controls = file['profiles'].last['controls']
      else
        file['profiles'].each do |profile|
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
        c_data[c_id]['rationale']      = control['tags']['rationale'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['cis_family']     = control['tags']['cis_family'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['cis_rid']        = control['tags']['cis_rid'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['cis_level']      = control['tags']['cis_level'] || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['impact']         = control['impact'].to_s || DATA_NOT_FOUND_MESSAGE
        c_data[c_id]['code']           = control['code'].to_s || DATA_NOT_FOUND_MESSAGE
      end
  
      @data['controls'] = c_data.values
    end
  end
end
