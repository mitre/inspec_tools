require 'csv'

module Utils
  class CSVUtil
    def self.unpack_csv(csv_string, file)
      csv = CSV.parse(csv_string)
      CSV.open(file, 'wb') do |csv_file|
        csv.each do |line|
          csv_file << line
        end
      end
    end
  end
end
