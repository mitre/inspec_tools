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
    CIS_2_NIST_XLSX = Roo::Spreadsheet.open(File.join(File.dirname(__FILE__), "../data/NIST_Map_02052020_CIS_Controls_Version_7.1_Implementation_Groups_1.2.xlsx"))
    LATEST_NIST_REV = 'Rev_4'.freeze

    def initialize(xlsx, mapping, name, verbose = false)
      @name = name
      @xlsx = xlsx
      @mapping = mapping
      @verbose = verbose
      @cis2Nist = get_cis_to_nist_control_mapping(CIS_2_NIST_XLSX)
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

    def get_cis_to_nist_control_mapping(spreadsheet)
      cis2Nist = {}
      spreadsheet.sheet(3).each do |row|
        if row[3].is_a? Numeric
          cis2Nist[row[3].to_s] = row[0]
        else
          cis2Nist[row[2].to_s] = row[0] unless (row[2] == "") || (row[2].to_i.nil?)
        end
      end
      cis2Nist
    end

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
      [ 1, 2 ].each do |level|
        @xlsx.sheet(level).each_row_streaming do |row|
          if row[@mapping['control.id']].nil? || !/^\d+(\.?\d)*$/.match(row[@mapping['control.id']].formatted_value)
            next
          end
          tag_pos = @mapping['control.tags']
          control = {}
          control['tags'] = {}
          control['id'] = control_prefix + '-' + row[@mapping['control.id']].formatted_value unless cell_empty?(@mapping['control.id']) || cell_empty?(row[@mapping['control.id']])
          control['title']  = row[@mapping['control.title']].formatted_value  unless cell_empty?(@mapping['control.title']) || cell_empty?(row[@mapping['control.title']])
          control['desc'] = ""
          control['desc'] = row[@mapping['control.desc']].formatted_value unless cell_empty?(row[@mapping['control.desc']])
          control['tags']['rationale'] = row[tag_pos['rationale']].formatted_value unless cell_empty?(row[tag_pos['rationale']])

          control['tags']['severity'] = level == 1 ? 'medium' : 'high'
          control['impact'] = Utils::InspecUtil.get_impact(control['tags']['severity'])
          control['tags']['ref'] = row[@mapping['control.ref']].formatted_value unless cell_empty?(@mapping['control.ref']) || cell_empty?(row[@mapping['control.ref']])
          control['tags']['cis_level'] = level unless level.nil?

          unless cell_empty?(row[tag_pos['cis_controls']])
            # cis_control must be extracted from CIS control column via regex
            cis_tags_array = row[tag_pos['cis_controls']].formatted_value.scan(/CONTROL:v(\d) (\d+)\.?(\d*)/).flatten
            cis_tags = [:revision, :section, :sub_section].zip(cis_tags_array).to_h
            control = apply_cis_and_nist_controls(control, cis_tags)
          end

          control['tags']['cis_rid'] = row[@mapping['control.id']].formatted_value unless cell_empty?(@mapping['control.id']) || cell_empty?(row[@mapping['control.id']])
          control['tags']['check'] = row[tag_pos['check']].formatted_value unless cell_empty?(tag_pos['check']) || cell_empty?(row[tag_pos['check']])
          control['tags']['fix'] = row[tag_pos['fix']].formatted_value unless cell_empty?(tag_pos['fix']) || cell_empty?(row[tag_pos['fix']])

          @controls << control
        end
      end
    end

    def cell_empty?(cell)
      return cell.empty? if cell.respond_to?(:empty?)

      cell.nil?
    end

    def apply_cis_and_nist_controls(control, cis_tags)
      control['tags']['cis_controls'] = []
      control['tags']['nist'] = []

      if cis_tags[:sub_section].nil? || cis_tags[:sub_section].blank?
        control['tags']['cis_controls'] << cis_tags[:section]
        control['tags']['nist'] << get_nist_control_for_cis([cis_tags[:section]])
      else
        control['tags']['cis_controls'] << "#{cis_tags[:section]}.#{cis_tags[:sub_section]}"
        control['tags']['nist'] << get_nist_control_for_cis([cis_tags[:section], cis_tags[:sub_section]])
      end

      control['tags']['nist'] << LATEST_NIST_REV unless control['tags']['nist'].nil?
      control['tags']['cis_controls'] << "Rev_#{cis_tags[:revision]}" unless cis_tags[:revision].nil?

      control
    end

    def get_nist_control_for_cis(section, sub_section=nil)
      return @cis2Nist[section] if sub_section.nil?

      @cis2Nist["#{section}.#{sub_section}"]
    end
  end
end
