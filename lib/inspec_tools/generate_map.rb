module InspecTools
  class GenerateMap
    attr_accessor :text

    def initialize(text = nil)
      @text = text.nil? ? default_text : text
    end

    def generate_example(file)
      File.write(file, @text)
    end

    private

    def default_text
      <<~YML
      # Setting csv_header to true will skip the csv file header
      skip_csv_header: true
      width   : 80


      control.id: 0
      control.title: 15
      control.desc: 16
      control.tags:
        severity: 1
        rid: 8
        stig_id: 3
        cci: 2
        check: 12
        fix: 10
      YML
    end
  end
end
