require 'yaml'
require_relative '../utilities/inspec_util'
require_relative '../utilities/csv_util'

# rubocop:disable Style/GuardClause

module InspecTools
  class CLI < Command
    desc 'xccdf2inspec', 'xccdf2inspec translates an xccdf file to an inspec profile'
    long_desc Help.text(:xccdf2inspec)
    option :xccdf, required: true, aliases: '-x'
    option :attributes, required: false, aliases: '-a'
    option :output, required: false, aliases: '-o', default: 'profile'
    option :format, required: false, aliases: '-f', enum: %w{ruby hash}, default: 'ruby'
    option :separate_files, required: false, type: :boolean, default: true, aliases: '-s'
    option :replace_tags, required: false, aliases: '-r'
    def xccdf2inspec
      xccdf = XCCDF.new(File.read(options[:xccdf]))
      profile = xccdf.to_inspec
      Utils::InspecUtil.unpack_inspec_json(options[:output], profile, options[:separate_files], options[:format])
      if !options[:attributes].nil?
        attributes = xccdf.to_attributes
        File.write(options[:attributes], YAML.dump(attributes))
      end
    end

    desc 'inspec2xccdf', 'inspec2xccdf translates an inspec profile and attributes files to an xccdf file'
    long_desc Help.text(:inspec2xccdf)
    option :inspec_json, required: true, aliases: '-j'
    option :attributes,  required: true, aliases: '-a'
    option :output, required: true, aliases: '-o'
    def inspec2xccdf
      json = File.read(options[:inspec_json])
      inspec_tool = InspecTools::Inspec.new(json)
      attr_hsh = YAML.load_file(options[:attributes])
      xccdf = inspec_tool.to_xccdf(attr_hsh)
      File.write(options[:output], xccdf)
    end

    desc 'csv2inspec', 'csv2inspec translates CSV to Inspec controls using a mapping file'
    long_desc Help.text(:csv2inspec)
    option :csv, required: true, aliases: '-c'
    option :mapping, required: true, aliases: '-m'
    option :verbose, required: false, type: :boolean, aliases: '-V'
    option :output, required: false, aliases: '-o', default: 'profile'
    option :format, required: false, aliases: '-f', enum: %w{ruby hash}, default: 'ruby'
    option :separate_files, required: false, type: :boolean, default: true, aliases: '-s'
    def csv2inspec
      csv = CSV.read(options[:csv], encoding: 'ISO8859-1')
      mapping = YAML.load_file(options[:mapping])
      profile = CSVTool.new(csv, mapping, options[:csv].split('/')[-1].split('.')[0], options[:verbose]).to_inspec
      Utils::InspecUtil.unpack_inspec_json(options[:output], profile, options[:separate_files], options[:format])
    end

    desc 'inspec2csv', 'inspec2csv translates Inspec controls to CSV'
    long_desc Help.text(:inspec2csv)
    option :inspec_json, required: true, aliases: '-j'
    option :output, required: true, aliases: '-o'
    option :verbose, required: false, type: :boolean, aliases: '-V'
    def inspec2csv
      csv = Inspec.new(File.read(options[:inspec_json])).to_csv
      Utils::CSVUtil.unpack_csv(csv, options[:output])
    end

    desc 'inspec2ckl', 'inspec2ckl translates an inspec json file to a Checklist file'
    long_desc Help.text(:inspec2ckl)
    option :inspec_json, required: true, aliases: '-j'
    option :output, required: true, aliases: '-o'
    option :verbose, type: :boolean, aliases: '-V'
    def inspec2ckl
      ckl = InspecTools::Inspec.new(File.read(options[:inspec_json])).to_ckl
      File.write(options[:output], ckl)
    end

    desc 'pdf2inspec', 'pdf2inspec translates a PDF Security Control Speficication to Inspec Security Profile'
    long_desc Help.text(:pdf2inspec)
    option :pdf, required: true, aliases: '-p'
    option :output, required: false, aliases: '-o', default: 'profile'
    option :debug, required: false, aliases: '-d', type: :boolean
    option :format, required: false, aliases: '-f', enum: %w{ruby hash}, default: 'ruby'
    option :separate_files, required: false, type: :boolean, default: true, aliases: '-s'
    def pdf2inspec
      pdf = File.open(options[:pdf])
      profile = InspecTools::PDF.new(pdf, options[:output], options[:output]).to_inspec
      Utils::InspecUtil.unpack_inspec_json(options[:output], profile, options[:separate_files], options[:format])
    end

    desc 'generate_map', 'Generates mapping template from CSV to Inspec Controls'
    def generate_map
      template = '
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
      '
      myfile = File.new('mapping.yml', 'w')
      myfile.puts template
      myfile.close
    end

    desc 'version', 'prints version'
    def version
      puts VERSION
    end
  end
end
