require 'docsplit'
require 'pdftotext'

module Util
  class ExtractPdfText
    def initialize(pdf, name)
      @pdf = pdf
      @name = name
      @extracted_text = ''
      read_text
    end

    def extracted_text
      @extracted_text
    end

    def read_text
      File.open("tmp/#{@name}.pdf", 'wb') { |f| f.write(@pdf.read.to_s) }
      docs = Dir["tmp/#{@name}.pdf"]
      Docsplit.extract_text(docs, ocr: false, output: Dir.tmpdir)
      txt_file = File.basename(@name, File.extname(@name)) + '.txt'
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
