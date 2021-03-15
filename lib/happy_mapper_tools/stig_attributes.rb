# encoding: utf-8

module HappyMapperTools
  module StigAttributes
    require 'happymapper'
    require 'nokogiri'
    require 'colorize'

    class ContentRef
      include HappyMapper
      tag 'check-content-ref'
      attribute :name, String, tag: 'name'
      attribute :href, String, tag: 'href'
    end

    class Check
      include HappyMapper
      tag 'check'

      element :content_ref, ContentRef, tag: 'check-content-ref'
      element :content, String, tag: 'check-content'
    end

    class Fix
      include HappyMapper
      tag 'fix'

      attribute :id, String, tag: 'id'
    end

    class DescriptionDetails
      include HappyMapper
      tag 'Details'

      element :vuln_discussion, String, tag: 'VulnDiscussion'
      element :false_positives, String, tag: 'FalsePositives'
      element :false_negatives, String, tag: 'FalseNegatives'
      element :documentable, Boolean, tag: 'Documentable'
      element :mitigations, String, tag: 'Mitigations'
      element :severity_override_guidance, String, tag: 'SeverityOverrideGuidance'
      element :security_override_guidance, String, tag: 'SecurityOverrideGuidance'
      element :potential_impacts, String, tag: 'PotentialImpacts'
      element :third_party_tools, String, tag: 'ThirdPartyTools'
      element :mitigation_controls, String, tag: 'MitigationControl'
      element :responsibility, String, tag: 'Responsibility'
      element :ia_controls, String, tag: 'IAControls'
    end

    class Description
      include HappyMapper
      tag 'description'

      content :details, DescriptionDetails

      detail_tags = %i(vuln_discussion false_positives false_negatives documentable
                       mitigations severity_override_guidance potential_impacts
                       third_party_tools mitigation_controls responsibility ia_controls
                       security_override_guidance)

      detail_tags.each do |name|
        define_method name do
          details.send(name)
        end
      end
    end

    class ReferenceInfo
      include HappyMapper
      tag 'reference'

      attribute :href, String, tag: 'href'
      element :dc_publisher, String, tag: 'publisher', namespace: 'dc'
      element :dc_source, String, tag: 'source', namespace: 'dc'
      element :dc_title, String, tag: 'title', namespace: 'dc'
      element :dc_type, String, tag: 'type', namespace: 'dc'
      element :dc_subject, String, tag: 'subject', namespace: 'dc'
      element :dc_identifier, String, tag: 'identifier', namespace: 'dc'
    end

    class Ident
      include HappyMapper
      attr_accessor :legacy
      attr_accessor :cci
      tag 'ident'
      attribute :system, String, tag: 'system'
      content :ident, String
    end

    class Rule
      include HappyMapper
      tag 'Rule'

      attribute :id, String, tag: 'id'
      attribute :severity, String, tag: 'severity'
      element :version, String, tag: 'version'
      element :title, String, tag: 'title'
      has_one :description, Description, tag: 'description'
      element :reference, ReferenceInfo, tag: 'reference'
      has_many :idents, Ident, tag: 'ident'
      element :fixtext, String, tag: 'fixtext'
      has_one :fix, Fix, tag: 'fix'
      has_one :check, Check, tag: 'check'
    end

    class Group
      include HappyMapper
      tag 'Group'

      attribute :id, String, tag: 'id'
      element :title, String, tag: 'title'
      element :description, String, tag: 'description'
      has_one :rule, Rule, tag: 'Rule'
    end

    class ReleaseDate
      include HappyMapper
      tag 'status'

      attribute :release_date, String, tag: 'date'
    end

    class Notice
      include HappyMapper
      tag 'notice'
      attribute :id, String, tag: 'id'
      attribute :xml_lang, String, namespace: 'xml', tag: 'lang'
      content :notice, String, tag: 'notice'
    end

    class Plaintext
      include HappyMapper
      tag 'plain-text'
      attribute :id, String, tag: 'id'
      content :plaintext, String
    end

    class Benchmark
      include HappyMapper
      tag 'Benchmark'

      has_one :release_date, ReleaseDate, tag: 'status'
      attribute :id, String, tag: 'id'
      element :status, String, tag: 'status'
      element :title, String, tag: 'title'
      element :description, String, tag: 'description'
      element :version, String, tag: 'version'
      element :notice, Notice, tag: 'notice'
      has_one :reference, ReferenceInfo, tag: 'reference'
      element :plaintext, Plaintext, tag: 'plain-text'
      has_many :group, Group, tag: 'Group'
    end

    class DescriptionDetailsType
      class << self
        def type
          DescriptionDetails
        end

        def apply(value)
          value = value.gsub('&', 'and')
          DescriptionDetails.parse "<Details>#{value}</Details>"
        rescue Nokogiri::XML::SyntaxError => e
          if e.to_s.include?('StartTag')
            report_invalid_start_tag(value, e)
          else
            report_disallowed_tags(value)
          end
        end

        def apply?(value, _convert_to_type)
          value.is_a?(String)
        end

        private

        def report_invalid_start_tag(value, error)
          puts error.to_s.colorize(:red)
          column = error.column - '<Details>'.length - 2
          puts "Error around #{value[column-10..column+10].colorize(:light_yellow)}"
          exit(1)
        end

        def report_disallowed_tags(value)
          allowed_tags = %w{VulnDiscussion FalsePositives FalseNegatives Documentable
                            Mitigations SeverityOverrideGuidance PotentialImpacts
                            PotentialImpacts ThirdPartyTools MitigationControl
                            Responsibility IAControl SecurityOverrideGuidance}

          tags_found = value.scan(%r{(?<=<)([^\/]*?)((?= \/>)|(?=>))}).to_a

          tags_found = tags_found.uniq.flatten.reject!(&:empty?)
          offending_tags = tags_found - allowed_tags

          if offending_tags.count > 1
            puts "\n\nThe non-standard tags: #{offending_tags.to_s.colorize(:red)}" \
                 ' were found in: ' + "\n\n#{value}"
          else
            puts "\n\nThe non-standard tag: #{offending_tags.to_s.colorize(:red)}" \
                 ' was found in: ' + "\n\n#{value}"
          end
          puts "\n\nPlease:\n "
          option_one = '(1) ' + '(best)'.colorize(:green) + ' Use the ' +
                       '`-r --replace-tags array` '.colorize(:light_yellow) +
                       '(case sensitive) option to replace the offending tags ' \
                       'during processing of the XCCDF ' \
                       'file to use the ' +
                       "`$#{offending_tags[0]}` " .colorize(:light_green) +
                       'syntax in your InSpec profile.'
          option_two = '(2) Update your XCCDF file to *not use* non-standard XCCDF ' \
                       'elements within ' +
                       '`&lt;`,`&gt;`, `<` '.colorize(:red) +
                       'or '.colorize(:default) +
                       '`>` '.colorize(:red) +
                       'as "placeholders", and use something that doesn\'t confuse ' \
                       'the XML parser, such as : ' +
                       "`$#{offending_tags[0]}`" .colorize(:light_green)
          puts option_one
          puts "\n"
          puts option_two
        end
      end
      HappyMapper::SupportedTypes.register DescriptionDetailsType
    end
  end
end
