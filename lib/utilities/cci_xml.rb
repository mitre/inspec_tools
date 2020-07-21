require 'nokogiri'

module Utils
  class CciXml
    def self.get_cci_list(cci_list_file)
      path = File.expand_path(File.join(File.expand_path(__dir__), '..', 'data', cci_list_file))
      raise "CCI list does not exist at #{path}" unless File.exist?(path)

      cci_list = Nokogiri::XML(File.open(path))
      cci_list.remove_namespaces!
    end
  end
end
