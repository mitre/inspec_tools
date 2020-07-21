require 'csv'
require 'yaml'
require 'digest'

require_relative '../utilities/inspec_util'
require_relative '../utilities/cci_xml'

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

    def to_inspec
      @controls = []
      @profile = {}
      @cci_xml = Utils::CciXml.get_cci_list('U_CCI_List.xml')
      insert_metadata
      parse_controls
      @profile['controls'] = @controls
      @profile['sha256'] = Digest::SHA256.hexdigest(@profile.to_s)
      @profile
    end

    private

    def insert_metadata
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

    def get_nist_reference(cci_number)
      item_node = @cci_xml.xpath("//cci_list/cci_items/cci_item[@id='#{cci_number}']")[0] unless @cci_xml.nil?
      return nil if item_node.nil?

      [] << item_node.xpath('./references/reference[not(@version <= preceding-sibling::reference/@version) and not(@version <=following-sibling::reference/@version)]/@index').text
    end

    def get_cci_number(cell)
      # Return nil if a mapping to the CCI was not provided or if there is not content in the CSV cell.
      return nil if cell.nil? || @mapping['control.tags']['cci'].nil?

      # If the content has been exported from STIG Viewer, the cell will have extra information
      cell.split("\n").first
    end

    def parse_controls
      @csv.each do |row|
        control = {}
        control['id']     = row[@mapping['control.id']]     unless @mapping['control.id'].nil? || row[@mapping['control.id']].nil?
        control['title']  = row[@mapping['control.title']]  unless @mapping['control.title'].nil? || row[@mapping['control.title']].nil?
        control['desc']   = row[@mapping['control.desc']]   unless @mapping['control.desc'].nil? || row[@mapping['control.desc']].nil?
        control['tags'] = {}
        cci_number = get_cci_number(row[@mapping['control.tags']['cci']])
        nist = get_nist_reference(cci_number) unless cci_number.nil?
        control['tags']['nist'] = nist unless nist.nil? || nist.include?(nil)
        @mapping['control.tags'].each do |tag|
          if tag.first == 'cci'
            control['tags'][tag.first] = cci_number
            next
          end
          control['tags'][tag.first] = row[tag.last] unless row[tag.last].nil?
        end
        unless @mapping['control.tags']['severity'].nil? || row[@mapping['control.tags']['severity']].nil?
          control['impact'] = Utils::InspecUtil.get_impact(row[@mapping['control.tags']['severity']])
          control['tags']['severity'] = Utils::InspecUtil.get_impact_string(control['impact'])
        end
        @controls << control
      end
    end
  end
end
