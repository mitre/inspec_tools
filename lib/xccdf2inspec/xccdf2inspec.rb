#!/usr/local/bin/ruby

# author: Matthew Dromazos

require 'nokogiri'
require 'json'
require_relative 'StigAttributes'
require_relative 'CCIAttributes'
require 'inspec/objects'
require 'word_wrap'
require 'pp'

WIDTH = 80

module InspecTo
  class Xccdf2Inspec
    def initialize(xccdf_path, cci_path, output, output_format, seperated, replace_tags)
      @cci_xml = File.read(cci_path)
      @xccdf_xml = File.read(xccdf_path)
      @output = 'inspec_profile' if output.nil?
      @output = output unless output.nil?
      @format = 'ruby' if output_format.nil?
      @format = output_format unless output_format.nil?
      @seperated = true if seperated.nil? || seperated == 'true'
      @seperated = false if seperated == 'false'
      @replace_tags = replace_tags.split(',').map(&:strip) unless replace_tags.nil?
      @controls = []
      replace_tags_in_xml unless replace_tags.nil?
      parse_xmls
      parse_controls
      generate_controls
      print_benchmark_info
    end
  
    private
  
    def wrap(s, width = WIDTH)
      s.gsub!("desc  \"\n    ", 'desc  "')
      s.gsub!(/\\r/, "\n")
      s.gsub!(/\\n/, "\n")
  
      WordWrap.ww(s.to_s, width)
    end
  
    def replace_tags_in_xml
      @replace_tags.each do |tag|
        @xccdf_xml = @xccdf_xml.gsub(/(&lt;|<)#{tag}(&gt;|>)/, "$#{tag}")
      end
    end
  
    def parse_xmls
      @cci_items = CCI_List.parse(@cci_xml)
      @xccdf_controls = Benchmark.parse(@xccdf_xml)
    end
  
    def parse_controls
      @xccdf_controls.group.each do |group|
        control = Inspec::Control.new
        control.id     = group.id
        control.title  = group.rule.title
        control.desc   = group.rule.description.vuln_discussion.split('Satisfies: ')[0]
        control.impact = get_impact(group.rule.severity)
        control.add_tag(Inspec::Tag.new('gtitle', group.title))
        control.add_tag(Inspec::Tag.new('satisfies', group.rule.description.vuln_discussion.split('Satisfies: ')[1].split(',').map(&:strip))) if group.rule.description.vuln_discussion.split('Satisfies: ').length > 1
        control.add_tag(Inspec::Tag.new('gid',      group.id))
        control.add_tag(Inspec::Tag.new('rid',      group.rule.id))
        control.add_tag(Inspec::Tag.new('stig_id',  group.rule.version))
        control.add_tag(Inspec::Tag.new('fix_id', group.rule.fix.id))
        control.add_tag(Inspec::Tag.new('cci', group.rule.idents))
        control.add_tag(Inspec::Tag.new('nist', @cci_items.fetch_nists(group.rule.idents)))
        control.add_tag(Inspec::Tag.new('false_negatives', group.rule.description.false_negatives)) if group.rule.description.false_negatives != ''
        control.add_tag(Inspec::Tag.new('false_positives', group.rule.description.false_positives)) if group.rule.description.false_positives != ''
        control.add_tag(Inspec::Tag.new('documentable', group.rule.description.documentable)) if group.rule.description.documentable != ''
        control.add_tag(Inspec::Tag.new('mitigations', group.rule.description.false_negatives)) if group.rule.description.mitigations != ''
        control.add_tag(Inspec::Tag.new('severity_override_guidance', group.rule.description.severity_override_guidance)) if group.rule.description.severity_override_guidance != ''
        control.add_tag(Inspec::Tag.new('potential_impacts', group.rule.description.potential_impacts)) if group.rule.description.potential_impacts != ''
        control.add_tag(Inspec::Tag.new('third_party_tools', group.rule.description.third_party_tools)) if group.rule.description.third_party_tools != ''
        control.add_tag(Inspec::Tag.new('mitigation_controls', group.rule.description.mitigation_controls)) if group.rule.description.mitigation_controls != ''
        control.add_tag(Inspec::Tag.new('responsibility', group.rule.description.responsibility)) if group.rule.description.responsibility != ''
        control.add_tag(Inspec::Tag.new('ia_controls', group.rule.description.ia_controls)) if group.rule.description.ia_controls != ''
        control.add_tag(Inspec::Tag.new('check', group.rule.check.check_content))
        control.add_tag(Inspec::Tag.new('fix', group.rule.fixtext))
  
        @controls << control
      end
    end
  
    def generate_controls
      Dir.mkdir @output.to_s unless Dir.exist?(@output.to_s)
      Dir.mkdir "#{@output}/controls" unless Dir.exist?("#{@output}/controls")
      Dir.mkdir "#{@output}/libaries" unless Dir.exist?("#{@output}/libraries")
      myfile = File.new("#{@output}/README.md", 'w')
      myfile.puts "# Example InSpec Profile\n\nthis example shows the implementation of an InSpec profile."
      if @seperated
        if @format == 'ruby'
          @controls.each do |control|
            file_name = control.id.to_s
            myfile = File.new("#{@output}/controls/#{file_name}.rb", 'w')
            myfile.puts wrap(control.to_ruby, WIDTH) + "\n"
            myfile.close
          end
        else
          @controls.each do |control|
            file_name = control.id.to_s
            myfile = File.new("#{@output}/controls/#{file_name}.rb", 'w')
            PP.pp(control.to_hash, myfile)
            myfile.close
          end
        end
      else
        myfile = File.new("#{@output}/controls/controls.rb", 'w')
        if @format == 'ruby'
          @controls.each do |control|
            myfile.puts wrap(control.to_ruby, WIDTH) + "\n"
          end
        else
          @controls.each do |control|
            control.desc = control.desc.strip
            PP.pp(control.to_hash, myfile)
          end
        end
        myfile.close
      end
    end
  
    # @!method print_benchmark_info(info)
    # writes benchmark info to profile inspec.yml file
    #
    def print_benchmark_info
      benchmark_info =
        "# encoding: utf-8 \n" \
        "# \n" \
        "=begin \n" \
        "----------------- \n" \
        "Benchmark: #{@xccdf_controls.title}  \n" \
        "Status: #{@xccdf_controls.status} \n\n" \
        'Description: ' + wrap(@xccdf_controls.description, width = WIDTH) + '' \
        "Release Date: #{@xccdf_controls.release_date.release_date} \n" \
        "Version: #{@xccdf_controls.version} \n" \
        "Publisher: #{@xccdf_controls.reference.publisher} \n" \
        "Source: #{@xccdf_controls.reference.source} \n" \
        "uri: #{@xccdf_controls.reference.href} \n" \
        "----------------- \n" \
        "=end \n\n"
  
      myfile = File.new("#{@output}/inspec.yml", 'w')
      myfile.puts benchmark_info
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
    def get_impact(severity)
      impact = case severity
               when 'low' then 0.3
               when 'medium' then 0.5
               else 0.7
               end
      impact
    end
  end
end
