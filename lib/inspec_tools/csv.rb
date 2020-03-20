require 'csv'
require 'nokogiri'
require 'inspec'
require 'word_wrap'
require 'yaml'
require 'digest'

require_relative '../utilities/inspec_util'

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/CyclomaticComplexity

module InspecTools
  # Methods for converting from CSV to various formats
  class CSVTool
    def initialize(csv, mapping, name, verbose = false)
      @name = name
      @csv = csv
      @mapping = mapping
      @verbose = verbose
      @csv.shift if @mapping['skip_csv_header']
    end

    def to_ckl
      # TODO
    end

    def to_xccdf
      # TODO
    end

    def to_inspec
      @controls = []
      @cci_xml = nil
      @profile = {}
      read_cci_xml
      insert_json_metadata
      parse_controls
      @profile['controls'] = @controls
      @profile['sha256'] = Digest::SHA256.hexdigest @profile.to_s
      @profile
    end

    private

    def insert_json_metadata
      @profile['name'] = @name
      @profile['title'] = 'InSpec Profile'
      @profile['maintainer'] = 'The Authors'
      @profile['copyright'] = 'The Authors'
      @profile['copyright_email'] = 'you@example.com'
      @profile['license'] = 'Apache-2.0'
      @profile['summary'] = 'An InSpec Compliance Profile'
      @profile['version'] = '0.1.0'
      @profile['supports'] = []
      @profile['attributes'] = []
      @profile['generator'] = {
        'name': 'inspec_tools',
        'version': VERSION
      }
    end

    def read_cci_xml
      cci_list_path = File.join(File.dirname(__FILE__), '../data/U_CCI_List.xml')
      @cci_xml = Nokogiri::XML(File.open(cci_list_path))
      @cci_xml.remove_namespaces!
    rescue StandardError => e
      puts "Exception: #{e.message}"
    end

    def get_nist_reference(cci_number)
      item_node = @cci_xml.xpath("//cci_list/cci_items/cci_item[@id='#{cci_number}']")[0] unless @cci_xml.nil?
      unless item_node.nil?
        nist_ref = item_node.xpath('./references/reference[not(@version <= preceding-sibling::reference/@version) and not(@version <=following-sibling::reference/@version)]/@index').text
        nist_ver = item_node.xpath('./references/reference[not(@version <= preceding-sibling::reference/@version) and not(@version <=following-sibling::reference/@version)]/@version').text
      end
      [nist_ref, nist_ver]
    end

    def parse_controls
      @csv.each do |row|
        print '.'
        control = {}
        control['id']     = row[@mapping['control.id']]     unless @mapping['control.id'].nil? || row[@mapping['control.id']].nil?
        control['title']  = row[@mapping['control.title']]  unless @mapping['control.title'].nil? || row[@mapping['control.title']].nil?
        control['desc']   = row[@mapping['control.desc']]   unless @mapping['control.desc'].nil? || row[@mapping['control.desc']].nil?
        control['tags'] = {}
        nist, nist_rev = get_nist_reference(row[@mapping['control.tags']['cci']]) unless @mapping['control.tags']['cci'].nil? || row[@mapping['control.tags']['cci']].nil?
        control['tags']['nist'] = [nist, 'Rev_' + nist_rev] unless nist.nil? || nist_rev.nil?
        @mapping['control.tags'].each do |tag|
          control['tags'][tag.first.to_s] = row[tag.last] unless row[tag.last].nil?
        end
        control['impact'] = Utils::InspecUtil.get_impact(row[@mapping['control.tags']['severity']]) unless @mapping['control.tags']['severity'].nil? || row[@mapping['control.tags']['severity']].nil?
        @controls << control
      end
    end
  end
end
