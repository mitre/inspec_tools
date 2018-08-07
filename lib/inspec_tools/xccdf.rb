require_relative '../happy_mapper_tools/StigAttributes'
require_relative '../happy_mapper_tools/CCIAttributes'
require_relative '../utils/inspec_util'

require 'digest'

module InspecTools
  class XCCDF
    def initialize(xccdf, replace_tags = nil)
      @xccdf = replace_tags_in_xccdf(replace_tags, @xccdf) unless replace_tags.nil?
      @cci_items = HappyMapperTools::CCIAttributes::CCI_List.parse(File.read('./data/U_CCI_List.xml'))
      @benchmark = HappyMapperTools::StigAttributes::Benchmark.parse(@xccdf)
    end
    
    def to_ckl
      
    end
    
    def to_csv
      
    end
    
    def to_inspec
      @profile = {}
      @controls = []
      insert_json_metadata
      insert_controls
      @profile['sha256'] = Digest::SHA256.hexdigest @profile.to_s
      @profile
    end
    
    def replace_tags_in_xccdf(replace_tags, xccdf_xml)
      replace_tags.each do |tag|
        xccdf_xml = xccdf_xml.gsub(/(&lt;|<)#{tag}(&gt;|>)/, "$#{tag}")
      end
      xccdf_xml
    end
    
    def publisher
      @benchmark.reference.publisher
    end
    
    def published
      @benchmark.release_date.release_date
    end

    private
    
    def insert_json_metadata
      @profile['name'] = @benchmark.title
      @profile['title'] = @benchmark.title
      @profile['maintainer'] = "The Authors"
      @profile['copyright'] = "The Authors"
      @profile['copyright_email'] = "you@example.com"
      @profile['license'] = "Apache-2.0"
      @profile['summary'] = @benchmark.description
      @profile['version'] = "0.1.0"
      @profile['supports'] = []
      @profile['attributes'] = []
      @profile['generator'] = {
          "name": "inspec",
          "version": Gem.loaded_specs["inspec"].version
      }
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
        control['tags']['check'] = group.rule.check.check_content
        control['tags']['fix'] = group.rule.fixtext
        @controls << control
      end
      @profile['controls'] = @controls
    end
  end
end