module InspecTools
  class CSV
    def initialize(csv, mapping_file, verbose)
      @csv = csv
      @mapping_file = mapping_file
      @verbose = verbose
    end
    
    def to_ckl
      
    end
    
    def to_xccdf
      
    end
    
    def to_inspec
      @controls = []
      @csv_handle = nil
      @cci_xml = nil
      @mapping = nil
      @profile = {}
      read_mapping
      read_csv
      read_cci_xml
      insert_json_metadata
      @profile['controls'] = parse_controls
      @profile['sha256'] = Digest::SHA256.hexdigest @profile.to_s
      @profile
    end
    
    private
    
    def insert_json_metadata
      @profile['name'] = @benchmark.title
      @profile['title'] = @benchmark.title
      @profile['maintainer'] = "The Authors"
      @profile['copyright'] = "The Authors"
      @profile['copyright_email'] = "you@example.com"
      @profile['license'] = "Apache-2.0"
      @profile['summary'] = @benchmark.description
      @profile['version'] = "0.1.0"
      @profile['supports'] = []
      @profile['attributes'] = []
      @profile['generator'] = {
          "name": "inspec",
          "version": Gem.loaded_specs["inspec"].version
      }
    end
    
    def read_cci_xml
      @cci_xml = Nokogiri::XML(File.open('data/U_CCI_List.xml'))
      @cci_xml.remove_namespaces!
    rescue => e
      puts "Exception: #{e.message}"
    end
    
    def get_nist_reference(cci_number)
      item_node = @cci_xml.xpath("//cci_list/cci_items/cci_item[@id='#{cci_number}']")[0] unless @cci_xml.nil?
      unless item_node.nil?
        nist_ref = item_node.xpath('./references/reference[not(@version <= preceding-sibling::reference/@version) and not(@version <=following-sibling::reference/@version)]/@index').text
        nist_ver = item_node.xpath('./references/reference[not(@version <= preceding-sibling::reference/@version) and not(@version <=following-sibling::reference/@version)]/@version').text
      end
      [nist_ref, nist_ver]
    end
  
    def wrap(s, width = WIDTH)
      s.gsub!(/\\r/, "   \n")
      WordWrap.ww(s.to_s, width)
    end
  
    def parse_controls
      @csv_handle.each do |row|
        print '.'
        control = Inspec::Control.new
        control.id     = row[@mapping['control.id']]     unless @mapping['control.id'].nil? || row[@mapping['control.id']].nil?
        control.title  = row[@mapping['control.title']]  unless @mapping['control.title'].nil? || row[@mapping['control.title']].nil?
        control.desc   = row[@mapping['control.desc']]   unless @mapping['control.desc'].nil? || row[@mapping['control.desc']].nil?
        nist, nist_rev = get_nist_reference(row[@mapping['control.tags']['cci']]) unless @mapping['control.tags']['cci'].nil? || row[@mapping['control.tags']['cci']].nil?
        control.add_tag(Inspec::Tag.new('nist', [nist, 'Rev_' + nist_rev])) unless nist.nil? || nist_rev.nil?
        @mapping['control.tags'].each do |tag|
          control.add_tag(Inspec::Tag.new(tag.first.to_s, row[tag.last])) unless row[tag.last].nil?
        end
        control.impact = get_impact(row[@mapping['control.tags']['severity']]) unless @mapping['control.tags']['severity'].nil? || row[@mapping['control.tags']['severity']].nil?
        @controls << control
      end
    end
  end
end