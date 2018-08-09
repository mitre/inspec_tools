#!/usr/bin/env ruby
# encoding: utf-8
# author: Aaron Lippold
# author: Rony Xavier rx294@nyu.edu

require "thor"
require 'nokogiri'
require_relative 'version'
require_relative 'inspec2xccdf'

module InspecTo
  class MyCLI < Thor
    desc 'exec', 'Inspec2xccdf convertes an Inspec profile into STIG XCCDF Document'
    option :inspec_json, required: true, aliases: '-j'
    option :attributes, required: true, aliases: '-a'
    option :xccdf_title, required: true, aliases: '-t'
    option :verbose, type: :boolean, aliases: '-V'
    def exec
      Inspec2xccdf.new(options[:inspec_json], options[:attributes], options[:xccdf_title], options[:verbose])
    end
  
    desc 'generate_attribute_file', 'Generates attributes yml file to provide required attributes for the XCCDF'
    def generate_attribute_file
      template = %q(
      # Attributes for the XCCDF Document
      benchmark.title : 'Application 5.x Security Technical Implementation Guide'
      benchmark.id : "Application_5-x_STIG" 
      benchmark.description : 'This Security Technical Implementation Guide is published as a tool to improve the security of Department of Defense (DoD) information systems. The requirements are derived from the National Institute of Standards and Technology (NIST) 800-53 and related documents. Comments or proposed revisions to this document should be sent via email to the following address: disa.stig_spt@mail.mil.'
      benchmark.version : '1'
      benchmark.status : accepted
      benchmark.status.date : "2017-09-27"
      benchmark.notice : ""
      benchmark.notice.id : "terms-of-use" 
      benchmark.plaintext : "Release 1 Benchmark Date 27 Sep 2017"
      benchmark.plaintext.id : 'release-info'
  
      reference.href : "http://iase.disa.mil"
      reference.dc.source : STIG.DOD.MIL
      reference.dc.publisher : DISA
      reference.dc.title : 'DPMS Target Application 5.x'
      reference.dc.subject : 'Application 5.x'
      reference.dc.type : 'DPMS Target'
      reference.dc.identifier : '3087'
  
      content_ref.href : 'DPMS_XCCDF_Benchmark_Application_5-x_STIG.xml'
      content_ref.name : 'M'
      )
      myfile = File.new('attributes.yml', 'w')
      myfile.puts template
      myfile.close
    end
  
    map %w{--help -h} => :help
    desc 'help', 'Help for using inspec2xccdf'
    def help
      puts "Inspec2xccdf convertes an Inspec profile into STIG XCCDF Document\n\n"
      puts "\t-j --inspec_json : Path to inspec Json file created using command 'inspec json <profile> > example.json"
      puts "\t-a --attributes  : Path to yml file that provides the required attributes for the XCCDF Document. Sample file can be generated using command 'inspec2xccdf generate_attribute_file'"
      puts "\t-t --xccdf_title : xccdf title"
      puts "\t-V --verbose     : verbose run"
  
      puts "\nexample: ./inspec2xccdf exec -j example.json -a attributes.yml -t application_name\n\n"
      puts "\nexample: ./inspec2xccdf generate_attribute_file to generate mapping template\n\n"
    end
  
    map %w{--version -v} => :print_version
    desc '--version, -v', "print's inspec2xccdf version"
    def print_version
      puts Inspec2Xccdf::VERSION
    end
  end
end

