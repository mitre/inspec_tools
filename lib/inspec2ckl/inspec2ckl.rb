#!/usr/local/bin/ruby
# encoding: utf-8
# author: Aaron Lippold
# author: Rony Xavier rx294@nyu.edu

require 'date'
require 'happymapper'
require 'nokogiri'
require 'json'
require_relative 'StigChecklist'

module InspecTo
  class Inspec2ckl < Checklist
    def initialize(json, cklist, title, date, output, verbose)
      @verbose = verbose
      @cklist = cklist
      @title = title
      @date = date
      inspec_json = File.read(json)
      @data = parse_json(inspec_json)
      @checklist = Checklist.new
      if cklist.nil?
        generate_ckl
      else
        update_ckl_file
      end
  
      File.write(output, @checklist.to_xml)
      puts "\nProcessed #{@data.keys.count} controls"
    end
  
    def clk_status(control)
      puts 'Full Status list: ' + control[:status].join(', ') if @verbose
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
      doc = File.open(@cklist) { |f| Nokogiri::XML(f) }
      @checklist = Checklist.parse(doc.to_s)
      @data.keys.each do | control_id |
        print '.'
        vuln = @checklist.where('Vuln_Num',control_id.to_s)
        vuln.status = clk_status(@data[control_id])
        vuln.finding_details << clk_finding_details(@data[control_id], vuln.status)
  
        if @verbose
          puts control_id
          puts @checklist.where('Vuln_Num',control_id.to_s).status
          puts @checklist.where('Vuln_Num',control_id.to_s).finding_details
          puts '====================================='
        end
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
  
    def generate_title
      if !title.nil?
        ckl_title = @title
      else
        ckl_title = "Untitled - Checklist Created from Automated InSpec Results JSON <profile_name>"
      end
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
  
    def parse_json(json)
      file = JSON.parse(json)
  
      @title = "Untitled - Checklist Created from Automated InSpec Results JSON; Profiles: #{file['profiles'].map { |x| x['name'] }.join(" | ")}" unless @title
      @title = @title + " Checklist Date: #{@date || Date.today.to_s}" #+ Date.today.to_s
  
      data = {}
      file['profiles'].each do |profile|
        profile['controls'].each do |control|
          c_id = control['id'].to_sym
          data[c_id] = {}
          data[c_id][:vuln_num]       = control['id'] unless control['id'].nil?
          data[c_id][:rule_title]     = control['title'] unless control['title'].nil?
          data[c_id][:vuln_discuss]   = control['desc'] unless control['desc'].nil?
          data[c_id][:severity]       = control['tags']['severity'] unless control['tags']['severity'].nil?
          data[c_id][:gid]            = control['tags']['gid'] unless control['tags']['gid'].nil?
          data[c_id][:group_title]    = control['tags']['gtitle'] unless control['tags']['gtitle'].nil?
          data[c_id][:rule_id]        = control['tags']['rid'] unless control['tags']['rid'].nil?
          data[c_id][:rule_ver]       = control['tags']['stig_id'] unless control['tags']['stig_id'].nil?
          data[c_id][:cci_ref]        = control['tags']['cci'] unless control['tags']['cci'].nil?
          data[c_id][:nist]           = control['tags']['nist'].join(' ') unless control['tags']['nist'].nil?
          data[c_id][:check_content]  = control['tags']['check'] unless control['tags']['check'].nil?
          data[c_id][:fix_text]       = control['tags']['fix'] unless control['tags']['fix'].nil?
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
  end
end
