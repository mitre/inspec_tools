module Utils
  class CisToNist
    def self.get_mapping(mapping_file)
      path = File.expand_path(File.join(File.expand_path(__dir__), '..', 'data', mapping_file))
      raise "CIS to NIST control mapping does not exist at #{path}. Has it been generated?" unless File.exist?(path)

      mapping = File.open(path)
      Marshal.load(mapping)
    end
  end
end
