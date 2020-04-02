require 'nokogiri'
require 'inspec-objects'
require 'word_wrap'
require 'yaml'
require 'digest'

require_relative '../utilities/inspec_util'

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/CyclomaticComplexity

module InspecTools
  # Methods for converting from XLS to various formats
  class XLSXTool
    def initialize(xlsx, mapping, name, verbose = false)
      @name = name
      @xlsx = xlsx
      @mapping = mapping
      @verbose = verbose
    end

    def to_ckl
      # TODO
    end

    def to_xccdf
      # TODO
    end

    def to_inspec(control_prefix)
      @controls = []
      @cci_xml = nil
      @profile = {}
      insert_json_metadata
      parse_cis_controls(control_prefix)
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

    def parse_cis_controls(control_prefix)
      cis2NistXls = Roo::Spreadsheet.open(File.join(File.dirname(__FILE__), "../data/NIST_Map_02052020_CIS_Controls_Version_7.1_Implementation_Groups_1.2.xlsx"))
      cis2Nist = {}
      cis2NistXls.sheet(3).each do |row|
        if row[3].is_a? Numeric
          cis2Nist[row[3].to_s] = row[0]
        else
          cis2Nist[row[2].to_s] = row[0] unless (row[2] == "") || (row[2].to_i.nil?)
        end
      end
      [ 1, 2 ].each do |level|
        @xlsx.sheet(level).each_row_streaming do |row|
          if row[@mapping['control.id']].nil? || !/^\d+(\.?\d)*$/.match(row[@mapping['control.id']].formatted_value)
            next
          end
          tag_pos = @mapping['control.tags']
          control = {}
          control['tags'] = {}
          control['id'] = control_prefix + '-' + row[@mapping['control.id']].formatted_value unless @mapping['control.id'].nil? || row[@mapping['control.id']].nil?
          control['title']  = row[@mapping['control.title']].formatted_value  unless @mapping['control.title'].nil? || row[@mapping['control.title']].nil?
          control['desc'] = ""
          control['desc'] = row[@mapping['control.desc']].formatted_value unless row[@mapping['control.desc']].nil?
          control['tags']['rationale'] = row[tag_pos['rationale']].formatted_value unless row[tag_pos['rationale']].empty?

          control['tags']['severity'] = level == 1 ? 'medium' : 'high'
          control['impact'] = Utils::InspecUtil.get_impact(control['tags']['severity'])
          control['tags']['ref'] = row[@mapping['control.ref']].formatted_value unless @mapping['control.ref'].nil? || row[@mapping['control.ref']].nil?
          control['tags']['cis_level'] = level unless level.nil?

          unless row[tag_pos['cis_controls']].empty?
            # cis_control must be extracted from CIS control column via regex
            control = handle_cis_tags(control, row[tag_pos['cis_controls']].formatted_value.scan(/CONTROL:v(\d) (\d+)\.?(\d*)/))
          end

          control['tags']['cis_rid'] = row[@mapping['control.id']].formatted_value unless @mapping['control.id'].nil? || row[@mapping['control.id']].nil?
          control['tags']['check'] = row[tag_pos['check']].formatted_value unless tag_pos['check'].nil? || row[tag_pos['check']].empty?
          control['tags']['fix'] = row[tag_pos['fix']].formatted_value unless tag_pos['fix'].nil? || row[tag_pos['fix']].empty?

          @controls << control
        end
      end
    end

    def handle_cis_tags(control, cis_tags)
      control['tags']['cis_controls'] = []
      control['tags']['nist'] = []

      cis_tags.each do |cis_tag|
        if cis_tag[2].nil? || cis_tag[2] == ""
          control['tags']['cis_controls'] << cis_tag[1].to_s
          control['tags']['nist'] << cis2Nist[cis_tag[1]]
        else
          control['tags']['cis_controls'] << cis_tag[1].to_s + "." + cis_tag[2].to_s
          control['tags']['nist'] << cis2Nist[cis_tag[1].to_s + "." + cis_tag[2].to_s]
        end
      end

      if not control['tags']['nist'].nil?
        control['tags']['nist'] << "Rev_4"
      end
      control['tags']['cis_controls'] << "Rev_" +  cis_tags.first[0] unless cis_tags[0].nil?
      control
    end
  end
end
