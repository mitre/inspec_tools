require_relative '../test_helper'

class InspecTest < Minitest::Test
  def test_that_xccdf_exists
    refute_nil ::InspecTools::Inspec
  end
  
  def test_inspec_init_with_valid_params
    inspec_json = File.read('examples/sample_json/single_control_results.json')
    assert(InspecTools::Inspec.new(inspec_json))
  end
  
  def test_inspec_init_with_invalid_params
    json = nil
    assert_raises(StandardError) { InspecTools::Inspec.new(json) }
  end
  
  def test_inspec_to_ckl
    inspec_json = File.read('examples/sample_json/single_control_results.json')
    inspec_tools = InspecTools::Inspec.new(inspec_json)
    ckl = inspec_tools.to_ckl
    assert(ckl)
  end
  
  def test_inspec_to_xccdf_results_json
    inspec_json = File.read('examples/sample_json/single_control_results.json')
    attributes = File.read('examples/attribute.json')
    inspec_tools = InspecTools::Inspec.new(inspec_json)
    xccdf = inspec_tools.to_xccdf(attributes)
    assert(xccdf)
  end
  
  def test_inspec_to_xccdf_profile_json
    inspec_json = File.read('examples/sample_json/single_control_profile.json')
    attributes = File.read('examples/attribute.json')
    inspec_tools = InspecTools::Inspec.new(inspec_json)
    xccdf = inspec_tools.to_xccdf(attributes)
    assert(xccdf)
  end
  
  def test_inspec_to_csv_results_json
    inspec_json = File.read('examples/sample_json/single_control_results.json')
    inspec_tools = InspecTools::Inspec.new(inspec_json)
    csv = inspec_tools.to_csv
    assert(csv)
  end
  
  def test_inspec_to_csv_profile_json
    inspec_json = File.read('examples/sample_json/single_control_profile.json')
    inspec_tools = InspecTools::Inspec.new(inspec_json)
    csv = inspec_tools.to_csv
    assert(csv)
  end
end