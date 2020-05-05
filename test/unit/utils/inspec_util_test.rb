require 'json'
require 'fileutils'
require_relative '../test_helper'
require_relative '../../../lib/utilities/inspec_util'

class InspecUtilTest < Minitest::Test
  def test_inspec_util_exists
    refute_nil Utils::InspecUtil
  end

  def test_string_to_impact
    # CVSS Terms True
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
      assert_equal(0.7, Utils::InspecUtil.get_impact(word))
    end

    # CVSS Terms False

    ['none' 'na' 'n/a' 'N/A' 'NONE' 'not applicable' 'not_applicable' 'NOT_APPLICABLE'].each do |word|
      assert_equal(0.0, Utils::InspecUtil.get_impact(word, false))
    end

    ['low', 'cat iii', 'cat   iii', 'CATEGORY III', 'cat 3'].each do |word|
      assert_equal(0.3, Utils::InspecUtil.get_impact(word, false))
    end

    ['medium', 'med', 'cat ii', 'cat   ii', 'CATEGORY II', 'cat 2'].each do |word|
      assert_equal(0.5, Utils::InspecUtil.get_impact(word, false))
    end

    ['high', 'cat i', 'cat   i', 'CATEGORY I', 'cat 1'].each do |word|
      assert_equal(0.7, Utils::InspecUtil.get_impact(word, false))
    end

    ['critical', 'crit', 'severe'].each do |word|
      assert_equal(1.0, Utils::InspecUtil.get_impact(word, false))
    end
  end

  def test_float_to_impact
    # CVSS Terms True
    assert_equal(0.0, Utils::InspecUtil.get_impact(0.01))
    assert_equal(0.3, Utils::InspecUtil.get_impact(0.1))
    assert_equal(0.3, Utils::InspecUtil.get_impact(0.2))
    assert_equal(0.3, Utils::InspecUtil.get_impact(0.3))
    assert_equal(0.5, Utils::InspecUtil.get_impact(0.4))
    assert_equal(0.5, Utils::InspecUtil.get_impact(0.5))
    assert_equal(0.5, Utils::InspecUtil.get_impact(0.6))
    assert_equal(0.7, Utils::InspecUtil.get_impact(0.7))
    assert_equal(0.7, Utils::InspecUtil.get_impact(0.8))
    assert_equal(0.7, Utils::InspecUtil.get_impact(0.9))

    # CVSS Terms False
    assert_equal(0.0, Utils::InspecUtil.get_impact(0.01, false))
    assert_equal(0.3, Utils::InspecUtil.get_impact(0.1, false))
    assert_equal(0.3, Utils::InspecUtil.get_impact(0.2, false))
    assert_equal(0.3, Utils::InspecUtil.get_impact(0.3, false))
    assert_equal(0.5, Utils::InspecUtil.get_impact(0.4, false))
    assert_equal(0.5, Utils::InspecUtil.get_impact(0.5, false))
    assert_equal(0.5, Utils::InspecUtil.get_impact(0.6, false))
    assert_equal(0.7, Utils::InspecUtil.get_impact(0.7, false))
    assert_equal(0.7, Utils::InspecUtil.get_impact(0.8, false))
    assert_equal(1.0, Utils::InspecUtil.get_impact(0.9, false))
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

  def test_get_impact_string
    # CVSS True
    assert_equal('none', Utils::InspecUtil.get_impact_string(0))
    assert_equal('none', Utils::InspecUtil.get_impact_string(0.01))
    assert_equal('low', Utils::InspecUtil.get_impact_string(0.1))
    assert_equal('low', Utils::InspecUtil.get_impact_string(0.2))
    assert_equal('low', Utils::InspecUtil.get_impact_string(0.3))
    assert_equal('medium', Utils::InspecUtil.get_impact_string(0.4))
    assert_equal('medium' ,Utils::InspecUtil.get_impact_string(0.5))
    assert_equal('medium', Utils::InspecUtil.get_impact_string(0.6))
    assert_equal('high', Utils::InspecUtil.get_impact_string(0.7))
    assert_equal('high', Utils::InspecUtil.get_impact_string(0.8))
    assert_equal('high', Utils::InspecUtil.get_impact_string(0.9))
    assert_equal('high', Utils::InspecUtil.get_impact_string(1.0))
    assert_equal('high', Utils::InspecUtil.get_impact_string(1))

    # CVSS False
    assert_equal('none', Utils::InspecUtil.get_impact_string(0, false))
    assert_equal('none', Utils::InspecUtil.get_impact_string(0.01, false))
    assert_equal('low', Utils::InspecUtil.get_impact_string(0.1, false))
    assert_equal('low', Utils::InspecUtil.get_impact_string(0.2, false))
    assert_equal('low', Utils::InspecUtil.get_impact_string(0.3, false))
    assert_equal('medium', Utils::InspecUtil.get_impact_string(0.4, false))
    assert_equal('medium' ,Utils::InspecUtil.get_impact_string(0.5, false))
    assert_equal('medium', Utils::InspecUtil.get_impact_string(0.6, false))
    assert_equal('high', Utils::InspecUtil.get_impact_string(0.7, false))
    assert_equal('high', Utils::InspecUtil.get_impact_string(0.8, false))
    assert_equal('critical', Utils::InspecUtil.get_impact_string(0.9, false))
    assert_equal('critical', Utils::InspecUtil.get_impact_string(1.0, false))
    assert_equal('critical', Utils::InspecUtil.get_impact_string(1, false))
  end

  def test_get_impact_string_error
    assert_raises(Utils::InspecUtil::ImpactInputError) {
      Utils::InspecUtil.get_impact_string(9001)
    }

    assert_raises(Utils::InspecUtil::ImpactInputError) {
      Utils::InspecUtil.get_impact_string(9001.1)
    }

    assert_raises(Utils::InspecUtil::ImpactInputError) {
      Utils::InspecUtil.get_impact_string(-1)
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
