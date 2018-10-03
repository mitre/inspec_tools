# author: Aaron Lippold (alippold@mitre.org)
# author: Rony Xavier (rxavier@mitre.org)
# author: Matthew Dromazos (mdromazos@mitre.org)

module HappyMapperTools
  module StigAttributes
    require 'happymapper'
    require 'nokogiri'
    require 'colorize'

    class Check
      include HappyMapper
      tag 'check'

      element 'check-content', String, tag: 'check-content'
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
                       third_party_tools mitigation_controls responsibility ia_controls)

      detail_tags.each do |name|
        define_method name do
          details.send(name)
        end
      end
    end

    class Rule
      include HappyMapper
      tag 'Rule'

      attribute :id, String, tag: 'id'
      attribute :severity, String, tag: 'severity'
      element :version, String, tag: 'version'
      element :title, String, tag: 'title'
      has_one :description, Description, tag: 'description'
      has_many :idents, String, tag: 'ident'
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

    class ReferenceInfo
      include HappyMapper
      tag 'reference'

      attribute :href, String, tag: 'href'
      element :publisher, String, tag: 'publisher', namespace: 'dc'
      element :source, String, tag: 'source', namespace: 'dc'
    end

    class ReleaseDate
      include HappyMapper
      tag 'status'

      attribute :release_date, String, tag: 'date'
    end

    class Benchmark
      include HappyMapper
      tag 'Benchmark'

      has_one :release_date, ReleaseDate, tag: 'status'
      element :status, String, tag: 'status'
      element :title, String, tag: 'title'
      element :description, String, tag: 'description'
      element :version, String, tag: 'version'
      has_one :reference, ReferenceInfo, tag: 'reference'
      has_many :group, Group, tag: 'Group'
    end

    class DescriptionDetailsType
      def self.type
        DescriptionDetails
      end

      def self.apply(value)
        value = value.gsub('&', 'and')
        DescriptionDetails.parse "<Details>#{value}</Details>"
      rescue Nokogiri::XML::SyntaxError
        allowed_tags = %w{VulnDiscussion FalsePositives FalseNegatives Documentable
                          Mitigations SeverityOverrideGuidance PotentialImpacts
                          PotentialImpacts ThirdPartyTools MitigationControl
                          Responsibility IAControls}

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
        # exit
      end

      def self.apply?(value, _convert_to_type)
        value.is_a?(String)
      end
    end
    HappyMapper::SupportedTypes.register DescriptionDetailsType
  end
end
