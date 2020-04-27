require 'json'
require 'fileutils'
require_relative '../test_helper'
require_relative '../../../lib/utilities/inspec_util'

class InspecUtilTest < Minitest::Test
  def test_inspec_util_exists
    refute_nil Utils::InspecUtil
  end

  def test_get_impact_string
    ['none' 'na' 'n/a' 'N/A' 'NONE' 'not applicable' 'not_applicable' 'NOT_APPLICABLE'].each do |word|
      assert_equal(0.0, Utils::InspecUtil.get_impact(word))
    end

    ['low', 'cat iii', 'cat   iii', 'CATEGORY III', 'cat 3'].each do |word|
      assert_equal(0.3, Utils::InspecUtil.get_impact(word))
    end

    ['medium', 'med', 'cat ii', 'cat   ii', 'CATEGORY II', 'cat 2'].each do |word|
      assert_equal(0.5, Utils::InspecUtil.get_impact(word))
    end

    ['high', 'cat i', 'cat   i', 'CATEGORY I', 'cat 1'].each do |word|
      assert_equal(0.7, Utils::InspecUtil.get_impact(word))
    end

    ['critical', 'crit', 'severe'].each do |word|
      assert_equal(1.0, Utils::InspecUtil.get_impact(word))
    end
  end

  def test_get_impact_float
    assert_equal(0.0, Utils::InspecUtil.get_impact(0.01))
    assert_equal(0.3, Utils::InspecUtil.get_impact(0.1))
    assert_equal(0.3, Utils::InspecUtil.get_impact(0.2))
    assert_equal(0.3, Utils::InspecUtil.get_impact(0.3))
    assert_equal(0.5, Utils::InspecUtil.get_impact(0.4))
    assert_equal(0.5, Utils::InspecUtil.get_impact(0.5))
    assert_equal(0.5, Utils::InspecUtil.get_impact(0.6))
    assert_equal(0.7, Utils::InspecUtil.get_impact(0.7))
    assert_equal(0.7, Utils::InspecUtil.get_impact(0.8))
    assert_equal(1.0, Utils::InspecUtil.get_impact(0.9))
  end

  def test_get_impact_error
    assert_raises(Utils::InspecUtil::SeverityInputError) {
      Utils::InspecUtil.get_impact('bad value')
    }
    assert_raises(Utils::InspecUtil::SeverityInputError) {
      Utils::InspecUtil.get_impact(9001)
    }
    assert_raises(Utils::InspecUtil::SeverityInputError) {
      Utils::InspecUtil.get_impact(9001.1)
    }
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
      FileUtils.rm_rf dir
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
