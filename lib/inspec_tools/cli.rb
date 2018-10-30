#!/usr/bin/env ruby

# author: Aaron Lippold (alippold@mitre.org)
# author: Rony Xavier (rxavier@mitre.org)
# author: Matthew Dromazos (mdromazos@mitre.org)

require 'thor'
require 'nokogiri'
require 'csv'
require 'yaml'
require_relative '../utilities/csv_util'

class MyCLI < Thor
  desc 'xccdf2inspec', 'xccdf2inspec translates an xccdf file to an inspec profile'
  option :xccdf, required: true, aliases: '-x'
  option :attributes, required: false, aliases: '-a'
  option :output, required: false, aliases: '-o', default: 'profile'
  option :format, required: false, aliases: '-f', enum: %w(ruby hash), default: 'ruby'
  option :separate_files, required: false, type: :boolean,  default: true,  aliases: '-s'
  option :replace_tags, required: false, aliases: '-r'
  def xccdf2inspec
    xccdf = InspecTools::XCCDF.new(File.read(options[:xccdf]))
    profile = xccdf.to_inspec
    Utils::InspecUtil.unpack_inspec_json(options[:output], profile, options[:separate_files], options[:format])
    if !options[:attributes].nil?
      attributes = xccdf.to_attributes
      File.write(options[:attributes], YAML.dump(attributes))
    end
  end

  desc 'inspec2xccdf', 'xccdf2inspec translates an xccdf file to an inspec profile'
  option :inspec_json, required: true, aliases: '-j'
  option :attributes,  required: true, aliases: '-a'
  option :output, required: true, aliases: '-o'
  def inspec2xccdf
    json = File.read(options[:inspec_json])
    inspec_tool = InspecTools::Inspec.new(json)
    xccdf = inspec_tool.to_xccdf(options['attributes'])
    File.write(options[:output], xccdf)
  end

  desc 'csv2inspec', 'csv2inspec translates CSV to Inspec controls'
  option :csv, required: true, aliases: '-c'
  option :mapping, required: true, aliases: '-m'
  option :verbose, required: false, type: :boolean, aliases: '-V'
  option :output, required: false, aliases: '-o', default: 'profile'
  option :format, required: false, aliases: '-f', enum: %w(ruby hash), default: 'ruby'
  option :separate_files, required: false, type: :boolean, default: true, aliases: '-s'
  def csv2inspec
    csv = CSV.read(options[:csv], encoding: 'ISO8859-1')
    mapping = YAML.load_file(options[:mapping])
    profile = InspecTools::CSVTool.new(csv, mapping, options[:csv].split('/')[-1].split('.')[0], options[:verbose]).to_inspec
    Utils::InspecUtil.unpack_inspec_json(options[:output], profile, options[:separate_files], options[:format])
  end

  desc 'inspec2csv', 'inspec2csv translates CSV to Inspec controls'
  option :inspec_json, required: true, aliases: '-j'
  option :output, required: true, aliases: '-o'
  option :verbose, required: false, type: :boolean, aliases: '-V'
  def inspec2csv
    csv = InspecTools::Inspec.new(File.read(options[:inspec_json])).to_csv
    Utils::CSVUtil.unpack_csv(csv, options[:output])
  end

  desc 'inspec2ckl', 'inspec2ckl translates an inspec json file to a Checklist file'
  option :inspec_json, required: true, aliases: '-j'
  option :output, required: true, aliases: '-o'
  option :verbose, type: :boolean, aliases: '-V'
  def inspec2ckl
    ckl = InspecTools::Inspec.new(File.read(options[:inspec_json])).to_ckl
    File.write(options[:output], ckl)
  end

  desc 'pdf2inspec', 'pdf2inspec translates a PDF Security Control Speficication to Inspec Security Profile'
  option :pdf, required: true, aliases: '-p'
  option :output, required: false, aliases: '-o', default: 'profile'
  option :debug, required: false, aliases: '-d', type: :boolean
  option :format, required: false, aliases: '-f', enum: %w(ruby hash), default: 'ruby'
  option :separate_files, required: false, type: :boolean, default: true, aliases: '-s'
  def pdf2inspec
    pdf = File.open(options[:pdf])
    profile = InspecTools::PDF.new(pdf, options[:output], options[:output]).to_inspec
    Utils::InspecUtil.unpack_inspec_json(options[:output], profile, options[:separate_files], options[:format])
  end

  desc 'generate_map', 'Generates mapping template from CSV to Inspec Controls'
  def generate_map
    template = %q(
    # Setting csv_header to true will skip the csv file header
    skip_csv_header: true
    width   : 80


    control.id: 0
    control.title: 15
    control.desc: 16
    control.tags:
            severity: 1
            rid: 8
            stig_id: 3
            cci: 2
            check: 12
            fix: 10
    )
    myfile = File.new('mapping.yml', 'w')
    myfile.puts template
    myfile.close
  end

  map %w{--help -h} => :help
  desc 'help', 'Help for using inspec_tools'
  def help
    puts "\nxccdf2inspec : translates an xccdf file to an Inspec Security Profile\n\n"
    puts "\ninspec2xccdf : translates an Inspec Security Profile to an xccdf file\n\n"
    puts "\ncsv2inspec   : translates CSV to Inspec Security Profile\n\n"
    puts "\ninspec2csv   : translates an Inspec Security Profile to a CSV file\n"
    puts "\ninspec2ckl   : translates an inspec json file to a Checklist file\n\n"
    puts "\npdf2inspec   : translates a PDF Security Control Specification to an Inspec Security Profile\n\n"
    puts "\nexample      : ./inspec_tools xccdf2inspec exec -c cci_list.xml -x xccdf_file.xml -o myprofile -f ruby \n\n"
  end

  map %w{--version -v} => :print_version
  desc '--version, -v', "print's inspec_tools version"
  def print_version
    puts ::InspecTools::VERSION
  end
end

MyCLI.start(ARGV)
