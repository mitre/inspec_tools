require 'roo'

module Util
  class ExtractNistMappings
    def initialize(file)
      @file = file
      @full_excel = Array.new
      @headers = Hash.new

      open_excel
      set_working_sheet
      get_headers
      retrieve_mappings
    end

    def open_excel
      @xlsx = Roo::Excelx.new(@file)
    end

    def full_excl
      @full_excel
    end

    def set_working_sheet
      @xlsx.default_sheet = 'VER 6.1 Controls'
    end

    def get_headers
      @xlsx.row(3).each_with_index {|header,i|
        @headers[header] = i
      }
    end

    def retrieve_mappings
      nist_ver = 4
      cis_ver = @xlsx.row(2)[4].split(' ')[-1]
      ctrl_count = 1
      ((@xlsx.first_row + 3)..@xlsx.last_row).each do |row_value|
        current_row = Hash.new
        if @xlsx.row(row_value)[@headers['NIST SP 800-53 Control #']].to_s != ''
          current_row[:nist] = @xlsx.row(row_value)[@headers['NIST SP 800-53 Control #']].to_s
        else
          current_row[:nist] = "Not Mapped"
        end
        current_row[:nist_ver] = nist_ver
        if @xlsx.row(row_value)[@headers['Control']].to_s == ''
          current_row[:cis] = ctrl_count.to_s
          ctrl_count += 1
        else
          current_row[:cis] = @xlsx.row(row_value)[@headers['Control']].to_s
        end
        current_row[:cis_ver] = cis_ver
        @full_excel << current_row
      end
    end
  end
end
