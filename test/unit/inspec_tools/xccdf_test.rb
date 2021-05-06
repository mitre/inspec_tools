require_relative '../test_helper'

class XCCDFTest < Minitest::Test
  def test_that_xccdf_exists
    refute_nil ::InspecTools::XCCDF
  end

  def test_xccdf_init_with_valid_params
    xccdf = File.read('examples/xccdf2inspec/data/U_RHEL_7_STIG_V3R3_Manual-xccdf.xml')
    assert(InspecTools::XCCDF.new(xccdf, true))
  end

  def test_xccdf_init_with_invalid_params
    xccdf = nil
    assert_raises(StandardError) { InspecTools::XCCDF.new(xccdf, true) }
  end

  def test_xccdf_attributes
    xccdf = InspecTools::XCCDF.new(File.read('examples/xccdf2inspec/data/U_RHEL_7_STIG_V3R3_Manual-xccdf.xml'), true)
    assert_equal(xccdf.publisher, "DISA")
    assert_equal(xccdf.published, "2021-03-01")
  end

  def test_to_inspec
    xccdf = InspecTools::XCCDF.new(File.read('examples/xccdf2inspec/data/U_RHEL_7_STIG_V3R3_Manual-xccdf.xml'), true)
    assert(xccdf.to_inspec)
  end

  def test_to_inspec_metadata
    xccdf = InspecTools::XCCDF.new(File.read('examples/xccdf2inspec/data/U_RHEL_7_STIG_V3R3_Manual-xccdf.xml'), true)
    inspec_json = xccdf.to_inspec
    assert_equal('RHEL_7_STIG', inspec_json['name'])
    assert_equal('Red Hat Enterprise Linux 7 Security Technical Implementation Guide', inspec_json['title'])
    assert_equal('The Authors', inspec_json['maintainer'])
    assert_equal('The Authors', inspec_json['copyright'])
    assert_equal('you@example.com', inspec_json['copyright_email'])
    assert_equal('Apache-2.0', inspec_json['license'])
    assert_equal('"This Security Technical Implementation Guide is published as a tool to improve the security of Department of Defense (DoD) information systems. The requirements are derived from the National Institute of Standards and Technology (NIST) 800-53 and related documents. Comments or proposed revisions to this document should be sent via email to the following address: disa.stig_spt@mail.mil."', inspec_json['summary'])
    assert_equal('0.1.0', inspec_json['version'])
    assert_empty(inspec_json['supports'])
    assert_empty(inspec_json['attributes'])
  end

  def test_controls_count
    xccdf = InspecTools::XCCDF.new(File.read('examples/xccdf2inspec/data/U_RHEL_7_STIG_V3R3_Manual-xccdf.xml'), true)
    inspec_json = xccdf.to_inspec
    assert_equal(249, inspec_json['controls'].count)
  end

  def test_control_id_flag
    xccdf = InspecTools::XCCDF.new(File.read('examples/xccdf2inspec/data/U_RHEL_7_STIG_V3R3_Manual-xccdf.xml'), true)
    vulnID_inspec_json = xccdf.to_inspec
    xccdf = InspecTools::XCCDF.new(File.read('examples/xccdf2inspec/data/U_RHEL_7_STIG_V3R3_Manual-xccdf.xml'), false)
    ruleID_inspec_json = xccdf.to_inspec
    assert(vulnID_inspec_json['controls'].first['id'].start_with? 'V-')
    assert(ruleID_inspec_json['controls'].first['id'].start_with? 'SV-')
  end
end
