require_relative '../test_helper'
require_relative '../../../lib/happy_mapper_tools/stig_checklist'

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
    attributes = JSON.parse(File.read('examples/attribute.json'))
    inspec_tools = InspecTools::Inspec.new(inspec_json)
    xccdf = inspec_tools.to_xccdf(attributes)
    assert(xccdf)
  end

  def test_inspec_to_xccdf_profile_json
    inspec_json = File.read('examples/sample_json/single_control_profile.json')
    attributes = JSON.parse(File.read('examples/attribute.json'))
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

  def test_inspec_to_ckl_generate_ckl
    inspec_json = { profiles: [{ controls: [{ id: 'V-221652' }] }] }.to_json
    metadata = JSON.parse(File.read('examples/inspec2ckl/metadata.json'))
    checklist = ::HappyMapperTools::StigChecklist::Checklist.new
    inspec_tools = InspecTools::Inspec.new(inspec_json, metadata)
    inspec_tools.instance_variable_set(:@data, {})
    inspec_tools.instance_variable_set(:@checklist, checklist)
    inspec_tools.send(:generate_ckl)
    version_data = checklist.stig.istig.stig_info.si_data.find { |d| d.name == 'version' }
    releaseinfo_data = checklist.stig.istig.stig_info.si_data.find { |d| d.name == 'releaseinfo' }
    title_info = checklist.stig.istig.stig_info.si_data.find { |d| d.name == 'title' }
    assert_equal(version_data.data, 'SI_DATA version, STIG_DATA STIGRef')
    assert_equal(releaseinfo_data.data, 'SI_DATA releaseinfo, STIG_DATA STIGRef')
    assert_equal(title_info.data, 'SI_DATA title, STIG_DATA STIGRef')
  end

  def test_inspec_to_ckl_generate_title
    inspec_json = { profiles: [{ controls: [{ id: 'V-221652' }] }] }.to_json
    metadata = JSON.parse(File.read('examples/inspec2ckl/metadata.json'))
    inspec_tools = InspecTools::Inspec.new(inspec_json, metadata)

    assert_equal('SI_DATA title, STIG_DATA STIGRef :: Version SI_DATA version, STIG_DATA STIGRef, SI_DATA releaseinfo, STIG_DATA STIGRef', inspec_tools.send(:generate_title))
  end
end
