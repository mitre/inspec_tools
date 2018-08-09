require_relative '../test_helper'

class InspecUtilTest < Minitest::Test
  def test_inspec_util_exists
    refute_nil Utils::InspecUtil
  end
  
  def test_get_impact
    assert_equal(0.3, Utils::InspecUtil.get_impact('low'))
    assert_equal(0.5, Utils::InspecUtil.get_impact('medium'))
    assert_equal(0.7, Utils::InspecUtil.get_impact('high'))
  end
  
  def test_unpack_inspec_json
    json = JSON.parse(File.read('./examples/sample_json/single_control_profile.json'))
    dir = Dir.mktmpdir
    begin
      Utils::InspecUtil.unpack_inspec_json(dir, json, false, 'ruby')
      assert(File.exist?(dir + '/inspec.yml'))
      assert(File.exist?(dir + '/README.md'))
      assert(Dir.exist?(dir + '/libraries'))
      assert(Dir.exist?(dir + '/controls'))
    ensure
      FileUtils.remove_entry dir
    end
  end
  
  def test_parse_data_for_xccdf
    json = JSON.parse(File.read('./examples/sample_json/single_control_profile.json'))
    xccdf_json = Utils::InspecUtil.parse_data_for_xccdf(json)
    assert_equal("Users must re-authenticate for privilege escalation.", xccdf_json['controls'][0]['title'])
    assert_equal("F-78301r2_fix", xccdf_json['controls'][0]['fix_id'])
  end
  
  def test_parse_data_for_ckl
    json = JSON.parse(File.read('./examples/sample_json/single_control_results.json'))
    ckl_json = Utils::InspecUtil.parse_data_for_ckl(json)
    assert_equal("Use human readable security markings", ckl_json[:"V-26680"][:rule_title])
    assert_equal("AC-16 (5) Rev_4", ckl_json[:"V-26680"][:nist])
  end
end