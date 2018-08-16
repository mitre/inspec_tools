# encoding: utf-8
# author: Matthew Dromazos dromazmj@gmail.com

require 'parslet'
require 'parslet/convenience'
require 'pp'

module Util
  class ControlParser < Parslet::Parser
    root :controls

    rule :controls do
      control.repeat(1)
    end

    rule :control do
      header >>
        applicability >>
        description.maybe >>
        rationale.maybe >>
        audit.maybe >>
        remediation.maybe >>
        impact.maybe >>
        default_value.maybe >>
        references.maybe >>
        cis_controls.maybe
    end

    rule :attribute_absent do
      str('Description:').absent? >>
        str('Rationale:').absent? >>
        str('Audit:').absent? >>
        str('Remediation:').absent? >>
        str('Impact:').absent? >>
        str('Default Value:').absent? >>
        str('References:').absent? >>
        str('CIS Controls:').absent? >>
        str('Profile Applicability::').absent? >>
        header.absent?
    end

    rule(:header) do
      newline.maybe >>
        spaces.maybe >>
        (section_num.as(:section_num) >>
        title.as(:title) >>
        score.as(:score)).as(:header) >>
        newline
    end

    rule(:title) do
      (str('(Scored)').absent? >> str('(Not Scored)').absent? >> str('(Not').absent? >> str('(Not ').absent? >> (anyChar | lparn | rparn | newline) | space).repeat(1)
    end

    rule :applicability do
      str('Profile Applicability:') >>
        newline.maybe >>
        lines('Description:').as(:applicability)
    end

    rule :section_num do
      (integer.repeat(1) >>
        dot).repeat(1) >>
        integer.repeat(1) >>
        space
    end

    rule :description do
      str('Description:') >>
        newline.maybe >>
        lines('Rationale:').as(:description)
    end

    rule :rationale do
      str('Rationale:') >>
        newline.maybe >>
        lines('Audit:').as(:rationale)
    end

    rule :audit do
      str('Audit:') >>
        newline.maybe >>
        lines('Remediation:').as(:audit)
    end

    rule :remediation do
      str('Remediation:') >>
        newline.maybe >>
        lines('Impact:').as(:remediation)
    end

    rule :impact do
      str('Impact:') >>
        newline.maybe >>
        lines('Default Value:').as(:impact)
    end

    rule :default_value do
      str('Default Value:') >>
        newline.maybe >>
        lines('References:').as(:default_value)
    end

    rule :references do
      str('References:') >>
        newline.maybe >>
        lines('CIS Controls:').as(:references)
    end

    rule :cis_controls do
      str('CIS Controls:') >>
        newline.maybe >>
        lines("\n").as(:cis_controls)
    end

    rule :blank_line do
      spaces >> newline >> spaces
    end

    rule :newline do
      str("\r").maybe >> str("\n")
    end

    rule :semicolon do
      str(';')
    end

    rule :spaces do
      space.repeat(0)
    end

    rule :space do
      match(/\s/)
    end

    rule :space? do
      space.maybe
    end

    rule :hyphen do
      str('-')
    end

    # @FIXME doesn't the parslet `any` function alreayd take care of this?
    rule :anyChar do
      match('.')
    end

    rule :integer do
      match('[0-9]').repeat(1)
    end

    rule :word do
      match('[a-zA-Z0-9/,\.:\'$-_\"*]').repeat(1)
    end

    rule :words do
      (space? >> word >> (space | dot | hyphen).maybe).repeat(1) >> (newline >> (word >> space).repeat(1)).maybe
    end

    def line_body(ending)
      (attribute_absent >> any).repeat(1)
    end

    def line(ending)
      line_body(ending)
    end

    def lines(ending)
      line(ending).as(:line).repeat
    end

    rule(:eol?) { str("\n").maybe }
    rule(:eof?) { any.absent? }

    rule :dot do
      str('.')
    end

    rule :real do
      integer.repeat(1) >>
        dot >>
        integer.repeat(1) >>
        dot.absent?
    end

    rule(:score) { lparn >> scored >> rparn }

    rule :lparn do
      str('(')
    end

    rule :rparn do
      str(')')
    end

    rule :scored do
      (str(' Scored') | str('Scored') | str('Not Scored') | (str('Not ') >> newline.maybe) | (str('Not') >> newline.maybe)).repeat
    end
  end

  class Trans < Parslet::Transform
    rule(line: simple(:text)) { text }
    rule(section_num: simple(:section), title: simple(:title), score: simple(:score)) { section + title + score }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation), impact: sequence(:impact), default_value: sequence(:default_value),
         references: sequence(:references), cis_controls: sequence(:cis_controls)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s,
             fix: remediation[0].to_s, impact: impact[0].to_s, default: default_value[0].to_s, ref: references[0].to_s, cis: cis_controls[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation),
         references: sequence(:references)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s,
             fix: remediation[0].to_s, ref: references[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation), impact: sequence(:impact),
         references: sequence(:references)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s,
             fix: remediation[0].to_s, impact: impact[0].to_s, ref: references[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation), impact: sequence(:impact)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s,
             fix: remediation[0].to_s, impact: impact[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation), default_value: sequence(:default_value),
         references: sequence(:references)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s,
             fix: remediation[0].to_s, default: default_value[0].to_s, ref: references[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation), impact: sequence(:impact), default_value: sequence(:default_value),
         references: sequence(:references)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s,
             fix: remediation[0].to_s, impact: impact[0].to_s, default: default_value[0].to_s, ref: references[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s, fix: remediation[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation), default_value: sequence(:default_value)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s,
             fix: remediation[0].to_s, default: default_value[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s, fix: remediation[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), references: sequence(:references)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s, ref: references[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         remediation: sequence(:remediation), impact: sequence(:impact)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", fix: remediation[0].to_s, impact: impact[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         remediation: sequence(:remediation), impact: sequence(:impact), references: sequence(:references)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", fix: remediation[0].to_s,
             impact: impact[0].to_s, ref: references[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description),
         audit: sequence(:audit), remediation: sequence(:remediation), default_value: sequence(:default_value),
         references: sequence(:references)) {
           { title: header.to_s, level: applicability[0].to_s, descr: description[0].to_s, check: audit[0].to_s, fix: remediation[0].to_s,
             default: default_value[0].to_s, ref: references[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), impact: sequence(:impact), default_value: sequence(:default_value)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s,
             impact: impact[0].to_s, default: default_value[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation), references: sequence(:references)) {
           { title: header.to_s, level: applicability[0].to_s, descr: rationale[0].to_s, check: audit[0].to_s, fix: remediation[0].to_s, ref: references[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         remediation: sequence(:remediation), references: sequence(:references)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", fix: remediation[0].to_s, ref: references[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), default_value: sequence(:default_value), references: sequence(:references)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s,
             default: default_value[0].to_s, ref: references[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation), impact: sequence(:impact), default_value: sequence(:default_value)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s, fix: remediation[0].to_s,
             impact: impact[0].to_s, default: default_value[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), impact: sequence(:impact), references: sequence(:references)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s, impact: impact[0].to_s, ref: references[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), impact: sequence(:impact)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s, impact: impact[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation), default_value: sequence(:default_value),
         references: sequence(:references),
         cis_controls: sequence(:cis_controls)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s, fix: remediation[0].to_s,
             default: default_value[0].to_s, ref: references[0].to_s, cis: cis_controls[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation), impact: sequence(:impact),
         references: sequence(:references),
         cis_controls: sequence(:cis_controls)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s, fix: remediation[0].to_s,
             impact: impact[0].to_s, ref: references[0].to_s, cis: cis_controls[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description), rationale: sequence(:rationale),
         audit: sequence(:audit), remediation: sequence(:remediation), references: sequence(:references),
         cis_controls: sequence(:cis_controls)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}", check: audit[0].to_s,
             fix: remediation[0].to_s, ref: references[0].to_s, cis: cis_controls[0].to_s }
         }
    rule(header: simple(:header), applicability: sequence(:applicability), description: sequence(:description),
         rationale: sequence(:rationale)) {
           { title: header.to_s, level: applicability[0].to_s, descr: "#{description[0]}#{rationale[0]}" }
         }
  end

  class PrepareData
    def initialize(clean_text)
      @parser = ControlParser.new
      @attributes = []

      data = parse(clean_text)

      @transformed_data = Trans.new.apply(data)
      # pp @transformed_data
      add_cis
    end

    def transformed_data
      @transformed_data
    end

    def parse(clean_text)
      # puts "############"
      # puts "Parse Data"
      # puts "############"
      @parser.parse(clean_text)
    rescue Parslet::ParseFailed => error
      puts error.parse_failure_cause.ascii_tree
    end

    def convert_str(value)
      value.to_s
    end

    def add_cis
      @transformed_data.map do |ctrl|
        if !ctrl[:cis] and ctrl[:ref]
          references = ctrl[:ref].split("\n")
          references.each do |ref|
            match = ref.scan(/(?<=#)\d{1,}\.\d{1,}/).map(&:inspect).join(',').gsub(/\"/, '').gsub(/,/, ' ')
            if !match.empty?
              puts match
              ctrl[:cis] = match.split(' ')
            end
          end
          if !ctrl[:cis]
            ctrl[:cis] = 'No CIS Control'
          end
        elsif !ctrl[:cis] and !ctrl[:ref]
          ctrl[:cis] = 'No CIS Control'
        elsif ctrl[:cis] and ctrl[:ref]
          ctrl[:cis] = ctrl[:cis].scan(/^\d{1,}[\.\d{1,}]*/)
        end
      end
    end
  end
end
