require 'pdf-reader'

module Util
  class ExtractPdfText
    def initialize(pdf)
      @pdf = pdf
      @extracted_text = ''
      read_text
    end

    attr_reader :extracted_text

    def read_text
      reader = PDF::Reader.new(@pdf.path)
      reader.pages.each do |page|
        @extracted_text += page.text
      end
    end
  end
end
