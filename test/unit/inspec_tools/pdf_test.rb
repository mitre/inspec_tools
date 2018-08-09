require_relative '../test_helper'

class PDFTest < Minitest::Test
  def test_that_csv_exists
    refute_nil ::InspecTools::PDF
  end
  
  def test_csv_init_with_valid_params
    pdf = File.open('examples/CIS_Ubuntu_Linux_16.04_LTS_Benchmark_v1.0.0.pdf')
    assert(InspecTools::PDF.new(pdf, 'test', false))
  end
  
  def test_csv_init_with_invalid_params
    pdf = nil
    assert_raises(StandardError) { InspecTools::PDF.new(pdf, 'test', false) }
  end
  
  def test_csv_to_inspec
    pdf = File.open('examples/CIS_Ubuntu_Linux_16.04_LTS_Benchmark_v1.0.0.pdf')
    pdf_tool = InspecTools::PDF.new(pdf, 'test', false)
    inspec_json = pdf_tool.to_inspec
    assert(inspec_json)
  end
end