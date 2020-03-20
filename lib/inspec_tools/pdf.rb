require 'digest'
require 'inspec'

require_relative '../utilities/inspec_util'
require_relative '../utilities/extract_pdf_text'
require_relative '../utilities/extract_nist_cis_mapping'
require_relative '../utilities/parser'
require_relative '../utilities/text_cleaner'

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/CyclomaticComplexity

module InspecTools
  class PDF
    def initialize(pdf, profile_name, debug = false)
      raise ArgumentError if pdf.nil?

      @pdf = pdf
      @name = profile_name
      @debug = debug
    end

    def to_inspec
      @controls = []
      @csv_handle = nil
      @cci_xml = nil
      @nist_mapping = nil
      @pdf_text = ''
      @clean_text = ''
      @transformed_data = ''
      @profile = {}
      read_pdf
      @title ||= extract_title
      clean_pdf_text
      transform_data
      read_excl
      insert_json_metadata
      @profile['controls'] = parse_controls
      @profile['sha256'] = Digest::SHA256.hexdigest @profile.to_s
      @profile
    end

    def to_csv
      # TODO: to_csv
    end

    def to_xccdf
      # TODO: to_xccdf
    end

    def to_ckl
      # TODO: to_ckl
    end

    private

    # converts passed in data into InSpec format
    def parse_controls
      controls = []
      @transformed_data.each do |contr|
        nist = find_nist(contr[:cis]) unless contr[:cis] == 'No CIS Control'
        control = {}
        control['id'] = 'M-' + contr[:title].split(' ')[0]
        control['title'] = contr[:title]
        control['desc'] = contr[:descr]
        control['impact'] = Utils::InspecUtil.get_impact('medium')
        control['tags'] = {}
        control['tags']['ref'] = contr[:ref] unless contr[:ref].nil?
        control['tags']['applicability'] = contr[:applicability] unless contr[:applicability].nil?
        control['tags']['cis_id'] = contr[:title].split(' ')[0] unless contr[:title].nil?
        control['tags']['cis_control'] = [contr[:cis], @nist_mapping[0][:cis_ver]] unless contr[:cis].nil? # tag cis_control: [5, 6.1] ##6.1 is the version
        control['tags']['cis_level'] = contr[:level] unless contr[:level].nil?
        control['tags']['nist'] = nist unless nist.nil? # tag nist: [AC-3, 4]  ##4 is the version
        control['tags']['check'] = contr[:check] unless contr[:check].nil?
        control['tags']['fix'] = contr[:fix] unless contr[:fix].nil?
        control['tags']['Default Value'] = contr[:default] unless contr[:default].nil?
        controls << control
      end
      controls
    end

    def insert_json_metadata
      @profile['name'] = @name
      @profile['title'] = @title
      @profile['maintainer'] = 'The Authors'
      @profile['copyright'] = 'The Authors'
      @profile['copyright_email'] = 'you@example.com'
      @profile['license'] = 'Apache-2.0'
      @profile['summary'] = 'An InSpec Compliance Profile'
      @profile['version'] = '0.1.0'
      @profile['supports'] = []
      @profile['attributes'] = []
      @profile['generator'] = {
        'name': 'inspec_tools',
        'version': VERSION
      }
    end

    def extract_title
      @pdf_text.match(/([^\n]*)\n/).captures[0]
    end

    def read_pdf
      @pdf_text = Util::ExtractPdfText.new(@pdf).extracted_text
      write_pdf_text if @debug
    end

    def clean_pdf_text
      @clean_text = Util::TextCleaner.new.clean_data(@pdf_text)
      write_clean_text if @debug
    end

    def transform_data
      @transformed_data = Util::PrepareData.new(@clean_text).transformed_data
    end

    def write_pdf_text
      File.write('pdf_text', @pdf_text)
    end

    def write_clean_text
      File.write('debug_text', @clean_text)
    end

    def read_excl
      nist_map_path = File.join(File.dirname(__FILE__), '../data/NIST_Map_09212017B_CSC-CIS_Critical_Security_Controls_VER_6.1_Excel_9.1.2016.xlsx')
      excel = Util::ExtractNistMappings.new(nist_map_path)
      @nist_mapping = excel.full_excl
    rescue StandardError => e
      puts "Exception: #{e.message}"
      puts 'Existing...'
      exit
    end
  end
end
