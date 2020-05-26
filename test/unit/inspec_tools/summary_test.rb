require 'csv'
require 'yaml'
require_relative '../test_helper'
require_relative '../../../lib/inspec_tools/csv'

class SummaryTest < Minitest::Test
  def test_that_summary_exists
    refute_nil ::InspecTools::Summary
  end

  def test_summary_init_with_valid_params
    inspec_json = File.read('examples/sample_json/rhel-simp.json')
    assert(InspecTools::Summary.new(inspec_json))
  end

  def test_summary_init_with_invalid_params
    json = nil
    assert_raises(StandardError) { InspecTools::Summary.new(json) }
  end

  def test_inspec_to_summary
    inspec_json = File.read('examples/sample_json/rhel-simp.json')
    inspec_tools = InspecTools::Summary.new(inspec_json)
    summary = inspec_tools.to_summary
    assert_equal(77, summary[:compliance])
    assert_equal(33, summary[:status][:failed][:medium])
  end

  def test_inspec_results_compliance_pass
    inspec_json = File.read('examples/sample_json/rhel-simp.json')
    threshold = YAML.safe_load('{compliance.min: 77, failed.critical.max: 0, failed.high.max: 3}')
    inspec_tools = InspecTools::Summary.new(inspec_json)
    assert_output(/Compliance threshold met/) { inspec_tools.threshold(threshold) }
  end

  def test_inspec_results_compliance_fail
    inspec_json = File.read('examples/sample_json/rhel-simp.json')
    threshold = YAML.safe_load('{compliance.min: 80, failed.critical.max: 0, failed.high.max: 0}')
    inspec_tools = InspecTools::Summary.new(inspec_json)
    assert_output(%r{Expected compliance.min:80 got:77(\r\n|\r|\n)Expected failed.high.max:0 got:3}) { inspec_tools.threshold(threshold) }
  end
end
