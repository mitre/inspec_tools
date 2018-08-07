#!/usr/local/bin/ruby
# encoding: utf-8
# author: Rony Xavier rx294@nyu.edu

require 'happymapper'
require 'nokogiri'
require 'json'
require 'yaml'
require_relative 'benchmark'
require_relative 'inspec_profile_parser'

module InspecTo
  class Inspec2xccdf < Benchmark
    def initialize(inspec_json_file, attribute_file, xccdf_title, verbose = false)
      @verbose = verbose
      @inspec_json_file = inspec_json_file
      @attribute_file = attribute_file
      @xccdf_title = xccdf_title
  
      @benchmark = Benchmark.new
      @controls = []
  
      read_inspec_json
      read_attributes
      generate_xccdf
    end
  
    def read_inspec_json
      profile_handle = InspecProfileParser.new(File.read(@inspec_json_file))
  
      unless profile_handle.content['status'].eql?('success')
          puts profile_handle.content['status']
          puts 'Existing...'
          exit
      end
  
      @controls = profile_handle.content['controls']
    rescue => e
      puts "Exception: #{e.message}"
      puts 'Existing...'
      exit
    end
  
    def read_attributes
      @attribute = YAML.load_file(@attribute_file)
    rescue => e
      puts "Exception: #{e.message}"
      puts 'Existing...'
      exit
    end
  
    def generate_xccdf
      populate_header
      # populate_profiles @todo populate profiles; not implemented now beacuse its use is depreciated
      populate_groups
      write_benchmark
    end
  
    def populate_header
      @benchmark.title = @attribute['benchmark.title']
      @benchmark.id =  @attribute['benchmark.id'] 
      @benchmark.description =  @attribute['benchmark.description']
      @benchmark.version =  @attribute['benchmark.version']
  
      @benchmark.status = Status.new
      @benchmark.status.status =  @attribute['benchmark.status'] 
      @benchmark.status.date =  @attribute['benchmark.status.date']
  
      @benchmark.notice = Notice.new
      @benchmark.notice.id =  @attribute['benchmark.notice']
  
      @benchmark.plaintext = Plaintext.new
      @benchmark.plaintext.plaintext =  @attribute['benchmark.plaintext']
      @benchmark.plaintext.id =  @attribute['benchmark.plaintext.id']
  
      @benchmark.reference = ReferenceBenchmark.new
      @benchmark.reference.href = @attribute['reference.href']
      @benchmark.reference.dc_publisher = @attribute['reference.href']
      @benchmark.reference.dc_source = @attribute['reference.dc.source']
  
    end
  
  def populate_groups
      group_array = []
      @controls.each do |control|
        group = Group.new
        group.id = control['id']
        group.title = control['gtitle']
        group.description = "<GroupDescription>#{control['gdescription']}</GroupDescription>"
        
        group.rule = Rule.new
        group.rule.id = control['rid']
        group.rule.severity = control['severity']
        group.rule.weight = control['rweight']
        group.rule.version = control['rversion']
        group.rule.title = control['title'].gsub(/\n/, ' ')
        group.rule.description = "<VulnDiscussion>#{control['desc'].gsub(/\n/, ' ')}</VulnDiscussion><FalsePositives></FalsePositives><FalseNegatives></FalseNegatives><Documentable>false</Documentable><Mitigations></Mitigations><SeverityOverrideGuidance></SeverityOverrideGuidance><PotentialImpacts></PotentialImpacts><ThirdPartyTools></ThirdPartyTools><MitigationControl></MitigationControl><Responsibility></Responsibility><IAControls></IAControls>"
  
        group.rule.reference = ReferenceGroup.new
        group.rule.reference.dc_publisher = @attribute['reference.dc.publisher']
        group.rule.reference.dc_title = @attribute['reference.dc.title']
        group.rule.reference.dc_subject = @attribute['reference.dc.subject']
        group.rule.reference.dc_type = @attribute['reference.dc.type']
        group.rule.reference.dc_identifier = @attribute['reference.dc.identifier']
  
        group.rule.ident = Ident.new
        group.rule.ident.system = 'http://iase.disa.mil/cci'
        group.rule.ident.ident = control['cci']
  
        group.rule.fixtext = Fixtext.new
        group.rule.fixtext.fixref = control['fixref']
        group.rule.fixtext.fixtext = control['fix']
  
        group.rule.fix = Fix.new
        group.rule.fix.id = control['fixref']
  
        group.rule.check = Check.new
        group.rule.check.system = control['checkref']
        group.rule.check.content_ref = ContentRef.new
        group.rule.check.content_ref.name = @attribute['content_ref.name']
        group.rule.check.content_ref.href = @attribute['content_ref.href']
        group.rule.check.content = control['check']
  
        group_array << group
      end
      @benchmark.group = group_array
    end
  
    def write_benchmark
      File.write("#{@xccdf_title}_xccdf.xml", @benchmark.to_xml)
    end
  end
end
