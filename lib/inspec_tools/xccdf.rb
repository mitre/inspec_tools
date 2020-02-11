require_relative '../happy_mapper_tools/stig_attributes'
require_relative '../happy_mapper_tools/cci_attributes'
require_relative '../utilities/inspec_util'

require 'digest'
require 'json'
require 'inspec'

module InspecTools
  # rubocop:disable Metrics/ClassLength
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/BlockLength
  class XCCDF
    def initialize(xccdf, replace_tags = nil)
      @xccdf = xccdf
      @xccdf = replace_tags_in_xccdf(replace_tags, @xccdf) unless replace_tags.nil?
      cci_list_path = File.join(File.dirname(__FILE__), '../data/U_CCI_List.xml')
      @cci_items = HappyMapperTools::CCIAttributes::CCI_List.parse(File.read(cci_list_path))
      # @cci_items = HappyMapperTools::CCIAttributes::CCI_List.parse(File.read('./data/U_CCI_List.xml'))
      @benchmark = HappyMapperTools::StigAttributes::Benchmark.parse(@xccdf)
    end

    def to_ckl
      # TODO: to_ckl
    end

    def to_csv
      # TODO: to_csv
    end

    def to_inspec
      @profile = {}
      @controls = []
      insert_json_metadata
      insert_controls
      @profile['sha256'] = Digest::SHA256.hexdigest @profile.to_s
      @profile
    end

    ####
    # extracts non-InSpec attributes
    ###
    # TODO there may be more attributes we want to extract, see data/attributes.yml for example
    def to_attributes # rubocop:disable Metrics/AbcSize
      @attribute = {}

      @attribute['benchmark.title'] = @benchmark.title
      @attribute['benchmark.id'] = @benchmark.id
      @attribute['benchmark.description'] = @benchmark.description
      @attribute['benchmark.version'] = @benchmark.version

      @attribute['benchmark.status'] = @benchmark.status
      @attribute['benchmark.status.date'] = @benchmark.release_date.release_date

      @attribute['benchmark.notice.id'] = @benchmark.notice.id

      @attribute['benchmark.plaintext'] = @benchmark.plaintext.plaintext
      @attribute['benchmark.plaintext.id'] = @benchmark.plaintext.id

      @attribute['reference.href'] = @benchmark.reference.href
      @attribute['reference.dc.publisher'] = @benchmark.reference.dc_publisher
      @attribute['reference.dc.source'] = @benchmark.reference.dc_source
      @attribute['reference.dc.title'] = @benchmark.group[0].rule.reference.dc_title if !@benchmark.group[0].nil?
      @attribute['reference.dc.subject'] = @benchmark.group[0].rule.reference.dc_subject if !@benchmark.group[0].nil?
      @attribute['reference.dc.type'] = @benchmark.group[0].rule.reference.dc_type if !@benchmark.group[0].nil?
      @attribute['reference.dc.identifier'] = @benchmark.group[0].rule.reference.dc_identifier if !@benchmark.group[0].nil?

      @attribute['content_ref.name'] = @benchmark.group[0].rule.check.content_ref.name if !@benchmark.group[0].nil?
      @attribute['content_ref.href'] = @benchmark.group[0].rule.check.content_ref.href if !@benchmark.group[0].nil?

      @attribute
    end

    def publisher
      @benchmark.reference.dc_publisher
    end

    def published
      @benchmark.release_date.release_date
    end

    def inject_metadata(metadata = '{}')
      json_metadata = JSON.parse(metadata)
      json_metadata.each do |key, value|
        @profile[key] = value
      end
    end

    private

    def replace_tags_in_xccdf(replace_tags, xccdf_xml)
      replace_tags.each do |tag|
        xccdf_xml = xccdf_xml.gsub(/(&lt;|<)#{tag}(&gt;|>)/, "$#{tag}")
      end
      xccdf_xml
    end

    def insert_json_metadata
      @profile['name'] = @benchmark.id
      @profile['title'] = @benchmark.title
      @profile['maintainer'] = 'The Authors' if @profile['maintainer'].nil?
      @profile['copyright'] = 'The Authors' if @profile['copyright'].nil?
      @profile['copyright_email'] = 'you@example.com' if @profile['copyright_email'].nil?
      @profile['license'] = 'Apache-2.0' if @profile['license'].nil?
      @profile['summary'] = "\"#{@benchmark.description.gsub('\\', '\\\\\\').gsub('"', '\"')}\""
      @profile['version'] = '0.1.0' if @profile['version'].nil?
      @profile['supports'] = []
      @profile['attributes'] = []
      @profile['generator'] = {
        'name': 'inspec_tools',
        'version': VERSION
      }
      @profile['plaintext'] = @benchmark.plaintext.plaintext
      @profile['status'] = "#{@benchmark.status} on #{@benchmark.release_date.release_date}"
      @profile['reference_href'] = @benchmark.reference.href
      @profile['reference_publisher'] = @benchmark.reference.dc_publisher
      @profile['reference_source'] = @benchmark.reference.dc_source
    end

    def insert_controls
      @benchmark.group.each do |group|
        control = {}
        control['id'] = group.id
        control['title'] = group.rule.title
        control['desc'] = group.rule.description.vuln_discussion.split('Satisfies: ')[0]
        control['impact'] = Utils::InspecUtil.get_impact(group.rule.severity)
        control['tags'] = {}
        control['tags']['gtitle'] = group.title
        control['tags']['satisfies'] = group.rule.description.vuln_discussion.split('Satisfies: ')[1].split(',').map(&:strip) if group.rule.description.vuln_discussion.split('Satisfies: ').length > 1
        control['tags']['gid'] = group.id
        control['tags']['rid'] = group.rule.id
        control['tags']['stig_id'] = group.rule.version
        control['tags']['fix_id'] = group.rule.fix.id
        control['tags']['cci'] = group.rule.idents
        control['tags']['nist'] = @cci_items.fetch_nists(group.rule.idents)
        control['tags']['false_negatives'] = group.rule.description.false_negatives if group.rule.description.false_negatives != ''
        control['tags']['false_positives'] = group.rule.description.false_positives if group.rule.description.false_positives != ''
        control['tags']['documentable'] = group.rule.description.documentable if group.rule.description.documentable != ''
        control['tags']['mitigations'] = group.rule.description.false_negatives if group.rule.description.mitigations != ''
        control['tags']['severity_override_guidance'] = group.rule.description.severity_override_guidance if group.rule.description.severity_override_guidance != ''
        control['tags']['potential_impacts'] = group.rule.description.potential_impacts if group.rule.description.potential_impacts != ''
        control['tags']['third_party_tools'] = group.rule.description.third_party_tools if group.rule.description.third_party_tools != ''
        control['tags']['mitigation_controls'] = group.rule.description.mitigation_controls if group.rule.description.mitigation_controls != ''
        control['tags']['responsibility'] = group.rule.description.responsibility if group.rule.description.responsibility != ''
        control['tags']['ia_controls'] = group.rule.description.ia_controls if group.rule.description.ia_controls != ''
        control['tags']['check'] = group.rule.check.content
        control['tags']['fix'] = group.rule.fixtext
        @controls << control
      end
      @profile['controls'] = @controls
    end
  end
end
