require 'json'
require 'roo'
require_relative '../utilities/inspec_util'
require_relative '../utilities/csv_util'

module InspecTools
  autoload :Help, 'inspec_tools/help'
  autoload :Command, 'inspec_tools/command'
  autoload :XCCDF, 'inspec_tools/xccdf'
  autoload :PDF, 'inspec_tools/pdf'
  autoload :CSVTool, 'inspec_tools/csv'
  autoload :CKL, 'inspec_tools/ckl'
  autoload :Inspec, 'inspec_tools/inspec'
  autoload :Summary, 'inspec_tools/summary'
  autoload :XLSXTool, 'inspec_tools/xlsx_tool'
  autoload :GenerateMap, 'inspec_tools/generate_map'
end

module InspecPlugins
  module InspecToolsPlugin
    class CliCommand < Inspec.plugin(2, :cli_command)
      POSSIBLE_LOG_LEVELS = %w{debug info warn error fatal}.freeze

      class_option :log_directory, type: :string, aliases: :l, desc: 'Provide log location'
      class_option :log_level, type: :string, desc: "Set the logging level: #{POSSIBLE_LOG_LEVELS}"

      subcommand_desc 'tools [COMMAND]', 'Runs inspec_tools commands through Inspec'

      desc 'xccdf2inspec', 'xccdf2inspec translates an xccdf file to an inspec profile'
      long_desc InspecTools::Help.text(:xccdf2inspec)
      option :xccdf, required: true, aliases: '-x'
      option :attributes, required: false, aliases: '-a'
      option :output, required: false, aliases: '-o', default: 'profile'
      option :format, required: false, aliases: '-f', enum: %w{ruby hash}, default: 'ruby'
      option :separate_files, required: false, type: :boolean, default: true, aliases: '-s'
      option :replace_tags, type: :array, required: false, aliases: '-r'
      option :metadata, required: false, aliases: '-m'
      def xccdf2inspec
        xccdf = InspecTools::XCCDF.new(File.read(options[:xccdf]), options[:replace_tags])
        profile = xccdf.to_inspec

        if !options[:metadata].nil?
          xccdf.inject_metadata(File.read(options[:metadata]))
        end

        Utils::InspecUtil.unpack_inspec_json(options[:output], profile, options[:separate_files], options[:format])
        if !options[:attributes].nil?
          attributes = xccdf.to_attributes
          File.write(options[:attributes], YAML.dump(attributes))
        end
      end

      desc 'inspec2xccdf', 'inspec2xccdf translates an inspec profile and attributes files to an xccdf file'
      long_desc InspecTools::Help.text(:inspec2xccdf)
      option :inspec_json, required: true, aliases: '-j',
                           desc: 'path to InSpec JSON file created'
      option :attributes,  required: true, aliases: '-a',
                           desc: 'path to yml file that provides the required attributes for the XCCDF document. These attributes are parts of XCCDF document which do not fit into the InSpec schema.'
      option :output, required: true, aliases: '-o',
                      desc: 'name or path to create the XCCDF and title to give the XCCDF'
      option :metadata, required: false, type: :string, aliases: '-m',
                        desc: 'path to JSON file with additional host metadata for the XCCDF file'
      def inspec2xccdf
        json = File.read(options[:inspec_json])
        metadata = options[:metadata] ? JSON.parse(File.read(options[:metadata])) : {}
        inspec_tool = InspecTools::Inspec.new(json, metadata)
        attr_hsh = YAML.load_file(options[:attributes])
        xccdf = inspec_tool.to_xccdf(attr_hsh)
        File.write(options[:output], xccdf)
      end

      desc 'csv2inspec', 'csv2inspec translates CSV to Inspec controls using a mapping file'
      long_desc InspecTools::Help.text(:csv2inspec)
      option :csv, required: true, aliases: '-c'
      option :mapping, required: true, aliases: '-m'
      option :verbose, required: false, type: :boolean, aliases: '-V'
      option :output, required: false, aliases: '-o', default: 'profile'
      option :format, required: false, aliases: '-f', enum: %w{ruby hash}, default: 'ruby'
      option :separate_files, required: false, type: :boolean, default: true, aliases: '-s'
      option :control_name_prefix, required: false, type: :string, aliases: '-p'
      def csv2inspec
        csv = CSV.read(options[:csv], encoding: 'ISO8859-1')
        mapping = YAML.load_file(options[:mapping])
        profile = InspecTools::CSVTool.new(csv, mapping, options[:csv].split('/')[-1].split('.')[0], options[:verbose]).to_inspec(control_name_prefix: options[:control_name_prefix])
        Utils::InspecUtil.unpack_inspec_json(options[:output], profile, options[:separate_files], options[:format])
      end

      desc 'xlsx2inspec', 'xlsx2inspec translates CIS XLSX to Inspec controls using a mapping file'
      long_desc InspecTools::Help.text(:xlsx2inspec)
      option :xlsx, required: true, aliases: '-x'
      option :mapping, required: true, aliases: '-m'
      option :control_name_prefix, required: true, aliases: '-p'
      option :verbose, required: false, type: :boolean, aliases: '-V'
      option :output, required: false, aliases: '-o', default: 'profile'
      option :format, required: false, aliases: '-f', enum: %w{ruby hash}, default: 'ruby'
      option :separate_files, required: false, type: :boolean, default: true, aliases: '-s'
      def xlsx2inspec
        xlsx = Roo::Spreadsheet.open(options[:xlsx])
        mapping = YAML.load_file(options[:mapping])
        profile = InspecTools::XLSXTool.new(xlsx, mapping, options[:xlsx].split('/')[-1].split('.')[0], options[:verbose]).to_inspec(options[:control_name_prefix])
        Utils::InspecUtil.unpack_inspec_json(options[:output], profile, options[:separate_files], options[:format])
      end

      desc 'inspec2csv', 'inspec2csv translates Inspec controls to CSV'
      long_desc InspecTools::Help.text(:inspec2csv)
      option :inspec_json, required: true, aliases: '-j'
      option :output, required: true, aliases: '-o'
      option :verbose, required: false, type: :boolean, aliases: '-V'
      def inspec2csv
        csv = InspecTools::Inspec.new(File.read(options[:inspec_json])).to_csv
        Utils::CSVUtil.unpack_csv(csv, options[:output])
      end

      desc 'inspec2ckl', 'inspec2ckl translates an inspec json file to a Checklist file'
      long_desc InspecTools::Help.text(:inspec2ckl)
      option :inspec_json, required: true, aliases: '-j'
      option :output, required: true, aliases: '-o'
      option :verbose, type: :boolean, aliases: '-V'
      option :metadata, required: false, aliases: '-m'
      def inspec2ckl
        metadata = '{}'
        if !options[:metadata].nil?
          metadata = File.read(options[:metadata])
        end
        ckl = InspecTools::Inspec.new(File.read(options[:inspec_json]), metadata).to_ckl
        File.write(options[:output], ckl)
      end

      desc 'pdf2inspec', 'pdf2inspec translates a PDF Security Control Speficication to Inspec Security Profile'
      long_desc InspecTools::Help.text(:pdf2inspec)
      option :pdf, required: true, aliases: '-p'
      option :output, required: false, aliases: '-o', default: 'profile'
      option :debug, required: false, aliases: '-d', type: :boolean, default: false
      option :format, required: false, aliases: '-f', enum: %w{ruby hash}, default: 'ruby'
      option :separate_files, required: false, type: :boolean, default: true, aliases: '-s'
      def pdf2inspec
        pdf = File.open(options[:pdf])
        profile = InspecTools::PDF.new(pdf, options[:output], options[:debug]).to_inspec
        Utils::InspecUtil.unpack_inspec_json(options[:output], profile, options[:separate_files], options[:format])
      end

      desc 'generate_map', 'Generates mapping template from CSV to Inspec Controls'
      def generate_map
        generator = InspecTools::GenerateMap.new
        generator.generate_example('mapping.yml')
      end

      desc 'generate_ckl_metadata', 'Generate metadata file that can be passed to inspec2ckl'
      def generate_ckl_metadata
        metadata = {}

        metadata['stigid'] = ask('STID ID: ')
        metadata['role'] = ask('Role: ')
        metadata['type'] = ask('Type: ')
        metadata['hostname'] = ask('Hostname: ')
        metadata['ip'] = ask('IP Address: ')
        metadata['mac'] = ask('MAC Address: ')
        metadata['fqdn'] = ask('FQDN: ')
        metadata['tech_area'] = ask('Tech Area: ')
        metadata['target_key'] = ask('Target Key: ')
        metadata['web_or_database'] = ask('Web or Database: ')
        metadata['web_db_site'] = ask('Web DB Site: ')
        metadata['web_db_instance'] = ask('Web DB Instance: ')

        metadata.delete_if { |_key, value| value.empty? }
        File.open('metadata.json', 'w') do |f|
          f.write(metadata.to_json)
        end
      end

      desc 'generate_inspec_metadata', 'Generate mapping file that can be passed to xccdf2inspec'
      def generate_inspec_metadata
        metadata = {}

        metadata['maintainer'] = ask('Maintainer: ')
        metadata['copyright'] = ask('Copyright: ')
        metadata['copyright_email'] = ask('Copyright Email: ')
        metadata['license'] = ask('License: ')
        metadata['version'] = ask('Version: ')

        metadata.delete_if { |_key, value| value.empty? }
        File.open('metadata.json', 'w') do |f|
          f.write(metadata.to_json)
        end
      end

      desc 'summary', 'summary parses an inspec results json to create a summary json'
      long_desc InspecTools::Help.text(:summary)
      option :inspec_json, required: true, aliases: '-j'
      option :json_full, type: :boolean, required: false, aliases: '-f'
      option :json_counts, type: :boolean, required: false, aliases: '-k'
      option :threshold_file, required: false, aliases: '-t'
      option :threshold_inline, required: false, aliases: '-i'

      def summary
        summary = InspecTools::Summary.new(options: options)
        summary.output_summary
      end

      desc 'compliance', 'compliance parses an inspec results json to check if the compliance level meets a specified threshold'
      long_desc InspecTools::Help.text(:compliance)
      option :inspec_json, required: true, aliases: '-j'
      option :threshold_file, required: false, aliases: '-f'
      option :threshold_inline, required: false, aliases: '-i'

      def compliance
        compliance = InspecTools::Summary.new(options: options)
        compliance.results_meet_threshold? ? exit(0) : exit(1)
      end
    end
  end
end

#=====================================================================#
#                        Pre-Flight Code
#=====================================================================#
help_commands = ['-h', '--help', 'help']
log_commands = ['-l', '--log-directory']
version_commands = ['-v', '--version', 'version']

#---------------------------------------------------------------------#
# Adjustments for non-required version commands
#---------------------------------------------------------------------#
unless (version_commands & ARGV).empty?
  puts InspecTools::VERSION
  exit 0
end

#---------------------------------------------------------------------#
# Adjustments for non-required log-directory
#---------------------------------------------------------------------#
ARGV.push("--log-directory=#{Dir.pwd}/logs") if (log_commands & ARGV).empty? && (help_commands & ARGV).empty?

# Push help to front of command so thor recognizes subcommands are called with help
if help_commands.any? { |cmd| ARGV.include? cmd }
  help_commands.each do |cmd|
    if (match = ARGV.delete(cmd))
      ARGV.unshift match
    end
  end
end
