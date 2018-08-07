#!/usr/local/bin/ruby
# encoding: utf-8
# author: Rony Xavier rx294@nyu.edu

require 'csv'
require 'nokogiri'
require 'inspec/objects'
require 'word_wrap'
require 'yaml'

WIDTH = 80

module InspecTo
  class Csv2Inspec
    def initialize(csv_file, mapping_file, verbose)
      @csv_file = csv_file
      @mapping_file = mapping_file
      @verbose = verbose
  
      @controls = []
      @csv_handle = nil
      @cci_xml = nil
      @mapping = nil
  
      read_mapping
      read_csv
      read_cci_xml
      parse_controls
      generate_controls
      puts "\nProcessed #{@controls.count} controls"
    end
  
    def read_csv
      @csv_handle = CSV.read(@csv_file, encoding: 'ISO8859-1')
      @csv_handle.shift if @mapping['skip_csv_header']
    rescue => e
      puts "Exception: #{e.message}"
      puts 'Existing...'
      exit
    end
  
    def read_mapping
      @mapping = YAML.load_file(@mapping_file)
    rescue => e
      puts "Exception: #{e.message}"
      puts 'Existing...'
      exit
    end
  
    def read_cci_xml
      @cci_xml = Nokogiri::XML(File.open('data/U_CCI_List.xml'))
      @cci_xml.remove_namespaces!
    rescue => e
      puts "Exception: #{e.message}"
    end
  
    def get_impact(severity)
      impact = case severity
               when 'low' then 0.3
               when 'medium' then 0.5
               else 0.7
               end
      impact
    end
  
    def get_nist_reference(cci_number)
      item_node = @cci_xml.xpath("//cci_list/cci_items/cci_item[@id='#{cci_number}']")[0] unless @cci_xml.nil?
      unless item_node.nil?
        nist_ref = item_node.xpath('./references/reference[not(@version <= preceding-sibling::reference/@version) and not(@version <=following-sibling::reference/@version)]/@index').text
        nist_ver = item_node.xpath('./references/reference[not(@version <= preceding-sibling::reference/@version) and not(@version <=following-sibling::reference/@version)]/@version').text
      end
      [nist_ref, nist_ver]
    end
  
    def wrap(s, width = WIDTH)
      s.gsub!(/\\r/, "   \n")
      WordWrap.ww(s.to_s, width)
    end
  
    def parse_controls
      @csv_handle.each do |row|
        print '.'
        control = Inspec::Control.new
        control.id     = row[@mapping['control.id']]     unless @mapping['control.id'].nil? || row[@mapping['control.id']].nil?
        control.title  = row[@mapping['control.title']]  unless @mapping['control.title'].nil? || row[@mapping['control.title']].nil?
        control.desc   = row[@mapping['control.desc']]   unless @mapping['control.desc'].nil? || row[@mapping['control.desc']].nil?
        nist, nist_rev = get_nist_reference(row[@mapping['control.tags']['cci']]) unless @mapping['control.tags']['cci'].nil? || row[@mapping['control.tags']['cci']].nil?
        control.add_tag(Inspec::Tag.new('nist', [nist, 'Rev_' + nist_rev])) unless nist.nil? || nist_rev.nil?
        @mapping['control.tags'].each do |tag|
          control.add_tag(Inspec::Tag.new(tag.first.to_s, row[tag.last])) unless row[tag.last].nil?
        end
        control.impact = get_impact(row[@mapping['control.tags']['severity']]) unless @mapping['control.tags']['severity'].nil? || row[@mapping['control.tags']['severity']].nil?
        @controls << control
      end
    end
  
    def generate_controls
      Dir.mkdir 'controls' unless Dir.exist?('controls')
      @controls.each do |control|
        file_name = control.id.to_s
        myfile = File.new("controls/#{file_name}.rb", 'w')
        width = WIDTH
        myfile.puts wrap(control.to_ruby, @mapping['width'])
        myfile.close
      end
    end
  end
end
