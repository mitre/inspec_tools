require_relative '../test_helper'

class XCCDFTest < Minitest::Test
  def test_that_xccdf_exists
    refute_nil ::InspecTools::XCCDF
  end

  def test_xccdf_init_with_valid_params
    xccdf = File.read('examples/xccdf2inspec/data/U_Red_Hat_Enterprise_Linux_7_STIG_V1R4_Manual-xccdf.xml')
    assert(InspecTools::XCCDF.new(xccdf))
  end

  def test_xccdf_init_with_invalid_params
    xccdf = nil
    assert_raises(StandardError) { InspecTools::XCCDF.new(xccdf) }
  end

  def test_xccdf_attributes
    xccdf = InspecTools::XCCDF.new(File.read('examples/xccdf2inspec/data/U_Red_Hat_Enterprise_Linux_7_STIG_V1R4_Manual-xccdf.xml'))
    assert_equal(xccdf.publisher, "DISA")
    assert_equal(xccdf.published, "2017-12-14")
  end

  def test_to_inspec
    xccdf = InspecTools::XCCDF.new(File.read('examples/xccdf2inspec/data/U_Red_Hat_Enterprise_Linux_7_STIG_V1R4_Manual-xccdf.xml'))
    assert(xccdf.to_inspec)
  end

  def test_to_inspec_metadata
    xccdf = InspecTools::XCCDF.new(File.read('examples/xccdf2inspec/data/U_Red_Hat_Enterprise_Linux_7_STIG_V1R4_Manual-xccdf.xml'))
    inspec_json = xccdf.to_inspec
    assert_equal(inspec_json['name'], "RHEL_7_STIG")
    assert_equal(inspec_json['title'], "Red Hat Enterprise Linux 7 Security Technical Implementation Guide")
    assert_equal(inspec_json['maintainer'], "The Authors")
    assert_equal(inspec_json['copyright'], "The Authors")
    assert_equal(inspec_json['copyright_email'], "you@example.com")
    assert_equal(inspec_json['license'], "Apache-2.0")
    assert_equal(inspec_json['summary'], "\"This Security Technical Implementation Guide is published as a tool to improve the security of Department of Defense (DoD) information systems. The requirements are derived from the National Institute of Standards and Technology (NIST) 800-53 and related documents. Comments or proposed revisions to this document should be sent via email to the following address: disa.stig_spt@mail.mil.\"")
    assert_equal(inspec_json['version'], "0.1.0")
    assert_equal(inspec_json['supports'], [])
    assert_equal(inspec_json['attributes'], [])
  end

  def test_controls_count
    xccdf = InspecTools::XCCDF.new(File.read('examples/xccdf2inspec/data/U_Red_Hat_Enterprise_Linux_7_STIG_V1R4_Manual-xccdf.xml'))
    inspec_json = xccdf.to_inspec
    assert_equal(240, inspec_json['controls'].count)
  end
end
