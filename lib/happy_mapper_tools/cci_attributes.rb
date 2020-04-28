# encoding: utf-8

require 'happymapper'
require 'nokogiri'

# rubocop:disable Naming/ClassAndModuleCamelCase

module HappyMapperTools
  module CCIAttributes
    class Reference
      include HappyMapper
      tag 'reference'

      attribute :creator, String, tag: 'creator'
      attribute :title, String, tag: 'title'
      attribute :version, String, tag: 'version'
      attribute :location, String, tag: 'location'
      attribute :index, String, tag: 'index'
    end

    class CCI_Item
      include HappyMapper
      tag 'cci_item'

      attribute :id, String, tag: 'id'
      element :status, String, tag: 'status'
      element :publishdate, String, tag: 'publishdate'
      element :contributor, String, tag: 'contributor'
      element :definition, String, tag: 'definition'
      element :type, String, tag: 'type'
      has_many :references, Reference, xpath: 'xmlns:references'
    end

    class Metadata
      include HappyMapper
      tag 'metadata'

      element :version, String, tag: 'version'
      element :publishdate, String, tag: 'publishdate'
    end

    class CCI_List
      include HappyMapper
      tag 'cci_list'

      attribute :xsi, String, tag: 'xsi', namespace: 'xmlns'
      attribute :schemaLocation, String, tag: 'schemaLocation', namespace: 'xmlns'
      has_one :metadata, Metadata, tag: 'metadata'
      has_many :cci_items, CCI_Item, xpath: 'xmlns:cci_items'

      def fetch_nists(ccis)
        ccis = [ccis] unless ccis.is_a?(Array)

        # some of the XCCDF files were having CCE- tags show up which
        # we don't support, not sure if this is a typo on their part or
        # we need to see about supporting CCE tags but ... for now
        filtered_ccis = ccis.select { |f| /CCI-/.match(f) }
        filtered_ccis.map do |cci|
          cci_items.find { |item| item.id == cci }.references.max_by(&:version).index
        end
      end
    end
  end
end

# rubocop:enable Naming/ClassAndModuleCamelCase
