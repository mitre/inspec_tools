require 'docsplit'

module Util
  class ExtractPdfText
    def initialize(pdf)
      @pdf = pdf
      @extracted_text = ''
      read_text
    end

    attr_reader :extracted_text

    def read_text
      Docsplit.extract_text([@pdf.path], ocr: false, output: Dir.tmpdir)
      txt_file = File.basename(@pdf.path, File.extname(@pdf.path)) + '.txt'
      txt_filename = Dir.tmpdir + '/' + txt_file

      File.open(txt_filename).each do |line|
        line = line.strip.gsub(/\A\p{Space}*|\p{Space}*\z/, '') + "\n"
        line = line.gsub(/\p{Space}{2}/, ' ')
        @extracted_text += line
      end
      File.delete(txt_filename)
    end
  end
end
