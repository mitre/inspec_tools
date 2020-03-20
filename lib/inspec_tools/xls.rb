require 'nokogiri'
require 'inspec/objects'
require 'word_wrap'
require 'yaml'
require 'digest'
require 'inspec'

require_relative '../utilities/inspec_util'

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/CyclomaticComplexity

module InspecTools
  # Methods for converting from XLS to various formats
  class XLSTool
    def initialize(xls, mapping, name, verbose = false)
      @name = name
      @xls = xls
      @mapping = mapping
      @verbose = verbose
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
      parse_cis_controls
      @profile['controls'] = @controls
      @profile['sha256'] = Digest::SHA256.hexdigest @profile.to_s
      puts @profile
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
        'name': 'inspec',
        'version': Gem.loaded_specs['inspec'].version
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

    def parse_cis_controls
      [ 1, 2 ].each do |level|
        @xls.sheet(level).each do |row|
          if row[@mapping['control.id']].nil? || row[@mapping['control.id']] == "Recommendation #" 
            next
          end
          tag_pos = @mapping['control.tags']
          control = {}
          control['id'] = 'M-' + row[@mapping['control.id']].to_s.split(' ')[0] unless @mapping['control.id'].nil? || row[@mapping['control.id']].nil?
          control['title']  = row[@mapping['control.title']]  unless @mapping['control.title'].nil? || row[@mapping['control.title']].nil?
          control['desc'] = ""
          @mapping['control.desc'].each do |i|
            control['desc'] << " " + row[i] unless row[i].nil?
          end
          control['tags'] = {}
          control['impact'] = Utils::InspecUtil.get_impact('medium')
          control['tags']['ref'] = row[@mapping['control.ref']] unless @mapping['control.ref'].nil? || row[@mapping['control.ref']].nil?
          control['tags']['cis_level'] = level unless level.nil?
          
          # nist = find_nist(row[:cis]) unless row[:cis] == 'No CIS Control'

          # cis_control must be extracted from CIS control column via regex
          cis_tags = row[tag_pos['cis_tag']].scan(/CONTROL:v(\d) (\d+)\.?(\d*)/)
          # control['tags']['nist'] = nist unless nist.nil? # tag nist: [AC-3, 4]  ##4 is the version
          control['tags']['cis_family'] = []
          cis_tags.each do |cis_tag| 
            if cis_tag[2].nil? || cis_tag[2] == ""
              control['tags']['cis_family'] << cis_tag[1].to_s
            else
              control['tags']['cis_family'] << cis_tag[1].to_s + "." + cis_tag[2].to_s
            end
          end
          control['tags']['cis_family'] << cis_tags[0][0] unless cis_tags[0].nil?
          # control['tags']['Default Value'] = row[:default] unless row[:default].nil?
          # applicability comes from the sheet number
          # control['tags']['applicability'] = row[@mapping['control.applicability']] unless @mapping['control.applicability'].nil? || row[@mapping['control.applicability']].nil?

          control['tags']['cis_rid'] = row[tag_pos['title']].to_s.split(' ')[0] unless tag_pos['title'].nil? || row[tag_pos['title']].nil?
          control['tags']['check'] = row[tag_pos['check']] unless tag_pos['check'].nil? || row[tag_pos['check']].nil?
          control['tags']['fix'] = row[tag_pos['fix']] unless tag_pos['fix'].nil? || row[tag_pos['fix']].nil?

          #@mapping['control.tags'].each do |tag|
          #  control['tags'][tag.first.to_s] = row[tag.last] unless row[tag.last].nil?
          #end
          # I dont think the CIS things have severities, need to ask Eugene for help
          # control['impact'] = Utils::InspecUtil.get_impact(row[@mapping['control.tags']['severity']]) unless @mapping['control.tags']['severity'].nil? || row[@mapping['control.tags']['severity']].nil?

          @controls << control
        end
      end
    end
  end
end
