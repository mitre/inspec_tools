require 'csv'
require 'yaml'
require_relative '../test_helper'
require_relative '../../../lib/inspec_tools/csv'

class SummaryTest < Minitest::Test
  def test_that_summary_exists
    refute_nil ::InspecTools::Summary
  end

  def test_summary_init_with_valid_params
    options = { options: {} }
    options[:options][:inspec_json] = 'examples/sample_json/rhel-simp.json'
    assert(InspecTools::Summary.new(**options))
  end

  def test_summary_init_with_invalid_params
    # File not found
    options = { options: {} }
    options[:options][:inspec_json] = 'does_not_exist'
    assert_raises(StandardError) { InspecTools::Summary.new(**options) }
  end

  def test_summary
    options = { options: {} }
    options[:options][:inspec_json] = 'examples/sample_json/rhel-simp.json'
    inspec_tools = InspecTools::Summary.new(**options)
    assert_equal(77, inspec_tools.summary[:compliance])
    assert_equal(33, inspec_tools.summary[:status][:failed][:medium])
  end

  def test_inspec_results_compliance_pass
    options = { options: {} }
    options[:options][:inspec_json] = 'examples/sample_json/rhel-simp.json'
    options[:options][:threshold_inline] = '{compliance.min: 77, failed.critical.max: 0, failed.high.max: 3}'
    inspec_tools = InspecTools::Summary.new(**options)
    assert_output(%r{Compliance threshold of \d\d% met}) { inspec_tools.results_meet_threshold? }
  end

  def test_inspec_results_compliance_fail
    options = { options: {} }
    options[:options][:inspec_json] = 'examples/sample_json/rhel-simp.json'
    options[:options][:threshold_inline] = '{compliance.min: 80, failed.critical.max: 0, failed.high.max: 0}'
    inspec_tools = InspecTools::Summary.new(**options)
    assert_output(%r{Expected compliance.min:80 got:77(\r\n|\r|\n)Expected failed.high.max:0 got:3}) { inspec_tools.results_meet_threshold? }

    options[:options][:threshold_inline] = '{compliance.max: 50}'
    inspec_tools = InspecTools::Summary.new(**options)
    assert_output(%r{Expected compliance.max:50 got:77}) { inspec_tools.results_meet_threshold? }

    options[:options][:threshold_file] = 'examples/sample_yaml/threshold.yaml'
    options[:options][:threshold_inline] = nil
    inspec_tools = InspecTools::Summary.new(**options)
    assert_output(%r{Expected compliance.min:81 got:77}) { inspec_tools.results_meet_threshold? }
  end

  def test_inline_overrides
    options = { options: {} }
    options[:options][:inspec_json] = 'examples/sample_json/rhel-simp.json'
    options[:options][:threshold_inline] = '{compliance.min: 77}'
    options[:options][:threshold_file] = 'examples/sample_yaml/threshold.yaml'
    inspec_tools = InspecTools::Summary.new(**options)
    inspec_tools.results_meet_threshold?
    assert_equal(77, inspec_tools.threshold['compliance.min'])
  end
end
