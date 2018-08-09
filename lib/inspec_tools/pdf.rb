require_relative '../utils/extract_pdf_text'
require_relative '../utils/extract_nist_cis_mapping'
require_relative '../utils/parser'
require_relative '../utils/text_cleaner'

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
      clean_pdf_text
      get_transformed_data
      read_excl
      insert_json_metadata
      @profile['controls'] = parse_controls
      @profile['sha256'] = Digest::SHA256.hexdigest @profile.to_s
      puts "\nProcessed #{@profile['controls'].count} controls"
      @profile
    end
    
    def to_csv
      
    end
    
    def to_xccdf
      
    end 
    
    def to_ckl
      
    end
    
    private
    
    # converts passed in data into InSpec format
    def parse_controls
      controls = []
      @transformed_data.each do |contr|
        print '.'
        nist = find_nist(contr[:cis]) unless contr[:cis] == "No CIS Control"
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
        control['tags']['nist'] = nist unless nist.nil?  # tag nist: [AC-3, 4]  ##4 is the version
        control['tags']['check'] = contr[:check] unless contr[:check].nil?
        control['tags']['fix'] = contr[:fix] unless contr[:fix].nil?
        control['tags']['Default Value'] = contr[:default] unless contr[:default].nil?
        controls << control
      end
      controls
    end
    
    def insert_json_metadata
      @profile['name'] = @name
      @profile['title'] = 'InSpec Profile'
      @profile['maintainer'] = "The Authors"
      @profile['copyright'] = "The Authors"
      @profile['copyright_email'] = "you@example.com"
      @profile['license'] = "Apache-2.0"
      @profile['summary'] = "An InSpec Compliance Profile"
      @profile['version'] = "0.1.0"
      @profile['supports'] = []
      @profile['attributes'] = []
      @profile['generator'] = {
          "name": "inspec",
          "version": Gem.loaded_specs["inspec"].version
      }
    end
    
    def read_pdf
      @pdf_text = Util::ExtractPdfText.new(@pdf, @name).extracted_text
    end

    def clean_pdf_text
      @clean_text = Util::TextCleaner.new.clean_data(@pdf_text)
      # File.open('data/debug_text').each do |line|
      #   @clean_text += line.to_s
      # end
      # p @clean_text
      write_clean_text if @debug
    end

    def get_transformed_data
      @transformed_data = Util::PrepareData.new(@clean_text).transformed_data
    end

    def write_clean_text
      File.write('data/debug_text', @clean_text)
    end

    def read_excl
      excel = Util::ExtractNistMappings.new('data/NIST_Map_09212017B_CSC-CIS_Critical_Security_Controls_VER_6.1_Excel_9.1.2016.xlsx')
      @nist_mapping = excel.full_excl
    rescue => e
      puts "Exception: #{e.message}"
      puts 'Existing...'
      exit
    end
  end
end