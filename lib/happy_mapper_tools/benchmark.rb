# encoding: utf-8

require 'happymapper'
require 'nokogiri'

# see: https://github.com/dam5s/happymapper
# Class Status maps from the 'status' from Benchmark XML file using HappyMapper
module HappyMapperTools
  module Benchmark
    class Status
      include HappyMapper
      tag 'status'
      attribute :date, String, tag: 'date'
      content :status, String, tag: 'status'
    end

    # Class Notice maps from the 'notice' from Benchmark XML file using HappyMapper
    class Notice
      include HappyMapper
      tag 'notice'
      attribute :id, String, tag: 'id'
      attribute :xml_lang, String, namespace: 'xml', tag: 'lang'
      content :notice, String, tag: 'notice'
    end

    # Class ReferenceBenchmark maps from the 'reference' from Benchmark XML file using HappyMapper
    class ReferenceBenchmark
      include HappyMapper
      tag 'reference'
      attribute :href, String, tag: 'href'
      element :dc_publisher, String, namespace: 'dc', tag: 'publisher'
      element :dc_source, String, namespace: 'dc', tag: 'source'
    end

    # Class ReferenceGroup maps from the 'reference' from Benchmark XML file using HappyMapper
    class ReferenceGroup
      include HappyMapper
      tag 'reference'
      element :dc_title, String, namespace: 'dc', tag: 'title'
      element :dc_publisher, String, namespace: 'dc', tag: 'publisher'
      element :dc_type, String, namespace: 'dc', tag: 'type'
      element :dc_subject, String, namespace: 'dc', tag: 'subject'
      element :dc_identifier, String, namespace: 'dc', tag: 'identifier'
    end

    # Class Plaintext maps from the 'plain-text' from Benchmark XML file using HappyMapper
    class Plaintext
      include HappyMapper
      tag 'plain-text'
      attribute :id, String, tag: 'id'
      content :plaintext, String
    end

    # Class Select maps from the 'Select' from Benchmark XML file using HappyMapper
    class Select
      include HappyMapper
      tag 'Select'
      attribute :idref, String, tag: 'idref'
      attribute :selected, String, tag: 'selected'
    end

    # Class Ident maps from the 'ident' from Benchmark XML file using HappyMapper
    class Ident
      include HappyMapper
      tag 'ident'
      attribute :system, String, tag: 'system'
      content :ident, String
    end

    # Class Fixtext maps from the 'fixtext' from Benchmark XML file using HappyMapper
    class Fixtext
      include HappyMapper
      tag 'fixtext'
      attribute :fixref, String, tag: 'fixref'
      content :fixtext, String
    end

    # Class Fix maps from the 'fixtext' from Benchmark XML file using HappyMapper
    class Fix
      include HappyMapper
      tag 'fixtext'
      attribute :id, String, tag: 'id'
    end

    # Class ContentRef maps from the 'check-content-ref' from Benchmark XML file using HappyMapper
    class ContentRef
      include HappyMapper
      tag 'check-content-ref'
      attribute :name, String, tag: 'name'
      attribute :href, String, tag: 'href'
    end

    # Class Check maps from the 'Check' from Benchmark XML file using HappyMapper
    class Check
      include HappyMapper
      tag 'check'
      attribute :system, String, tag: 'system'
      element :content_ref, ContentRef, tag: 'check-content-ref'
      element :content, String, tag: 'check-content'
    end

    class MessageType
      include HappyMapper
      attribute :severity, String, tag: 'severity'
      content :message, String
    end

    class RuleResultType
      include HappyMapper
      attribute :idref, String, tag: 'idref'
      attribute :severity, String, tag: 'severity'
      attribute :time, String, tag: 'time'
      attribute :weight, String, tag: 'weight'
      element :result, String, tag: 'result'
      # element override - Not implemented. Does not apply to Inspec execution
      has_many :ident, Ident, tag: 'ident'
      # Note: element metadata not implemented at this time
      has_many :message, MessageType, tag: 'message'
      has_many :instance, String, tag: 'instance'
      element :fix, Fix, tag: 'fix'
      element :check, Check, tag: 'check'
    end

    class ScoreType
      include HappyMapper

      def initialize(system, maximum, score)
        @system = system
        @maximum = maximum
        @score = score
      end

      attribute :system, String, tag: 'system'
      attribute :maximum, String, tag: 'maximum' # optional attribute
      content :score, String
    end

    class CPE2idrefType
      include HappyMapper
      attribute :idref, String, tag: 'idref'
    end

    class IdentityType
      include HappyMapper
      attribute :authenticated, Boolean, tag: 'authenticated'
      attribute :privileged, Boolean, tag: 'privileged'
      content :identity, String
    end

    class Fact
      include HappyMapper
      attribute :name, String, tag: 'name'
      attribute :type, String, tag: 'type'
      content :fact, String
    end

    class TargetFact
      include HappyMapper
      has_many :fact, Fact, tag: 'fact'
    end

    class TestResult
      include HappyMapper
      # Note: element benchmark not implemented at this time since this is same file
      # Note: element title not implemented due to no mapping from Chef Inspec
      element :remark, String, tag: 'remark'
      has_many :organization, String, tag: 'organization'
      element :identity, IdentityType, tag: 'identity'
      element :target, String, tag: 'target'
      has_many :target_address, String, tag: 'target-address'
      element :target_facts, TargetFact, tag: 'target-facts'
      element :platform, CPE2idrefType, tag: 'platform'
      # Note: element profile not implemented since Benchmark profile is also not implemented
      has_many :rule_result, RuleResultType, tag: 'rule-result'
      has_many :score, ScoreType, tag: 'score' # One minimum
      # Note: element signature not implemented due to no mapping from Chef Inspec
      attribute :id, String, tag: 'id'
      attribute :starttime, String, tag: 'start-time'
      attribute :endtime, String, tag: 'end-time'
      # Note: attribute test-system not implemented at this time due to unknown CPE value for Chef Inspec
      attribute :version, String, tag: 'version'
    end

    # Class Profile maps from the 'Profile' from Benchmark XML file using HappyMapper
    class Profile
      include HappyMapper
      tag 'Profile'
      attribute :id, String, tag: 'id'
      element :title, String, tag: 'title'
      element :description, String, tag: 'description'
      has_many :select, Select, tag: 'select'
    end

    # Class Rule maps from the 'Rule' from Benchmark XML file using HappyMapper
    class Rule
      include HappyMapper
      tag 'Rule'
      attribute :id, String, tag: 'id'
      attribute :severity, String, tag: 'severity'
      attribute :weight, String, tag: 'weight'
      element :version, String, tag: 'version'
      element :title, String, tag: 'title'
      element :description, String, tag: 'description'
      element :reference, ReferenceGroup, tag: 'reference'
      has_many :ident, Ident, tag: 'ident'
      element :fixtext, Fixtext, tag: 'fixtext'
      element :fix, Fix, tag: 'fix'
      element :check, Check, tag: 'check'
    end

    # Class Group maps from the 'Group' from Benchmark XML file using HappyMapper
    class Group
      include HappyMapper
      tag 'Group'
      attribute :id, String, tag: 'id'
      element :title, String, tag: 'title'
      element :description, String, tag: 'description'
      element :rule, Rule, tag: 'Rule'
    end

    # Class Benchmark maps from the 'Benchmark' from Benchmark XML file using HappyMapper
    class Benchmark
      include HappyMapper
      tag 'Benchmark'
      register_namespace 'dsig', 'http://www.w3.org/2000/09/xmldsig#'
      register_namespace 'xsi', 'http://www.w3.org/2001/XMLSchema-instance'
      register_namespace 'cpe', 'http://cpe.mitre.org/language/2.0'
      register_namespace 'xhtml', 'http://www.w3.org/1999/xhtml'
      register_namespace 'dc', 'http://purl.org/dc/elements/1.1/'
      attribute :id, String, tag: 'id'
      attribute :xmlns, String, tag: 'xmlns'
      element :status, Status, tag: 'status'
      element :title, String, tag: 'title'
      element :description, String, tag: 'description'
      element :notice, Notice, tag: 'notice'
      element :reference, ReferenceBenchmark, tag: 'reference'
      element :plaintext, Plaintext, tag: 'plain-text'
      element :version, String, tag: 'version'
      has_many :profile, Profile, tag: 'Profile'
      has_many :group, Group, tag: 'Group'
      element :testresult, TestResult, tag: 'TestResult'
    end
  end
end
