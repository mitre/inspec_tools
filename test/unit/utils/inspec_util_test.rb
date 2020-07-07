require 'json'
require 'fileutils'
require_relative '../test_helper'
require_relative '../../../lib/utilities/inspec_util'

class InspecUtilTest < Minitest::Test # rubocop:disable Metrics/ClassLength
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
      assert_equal(0.0, Utils::InspecUtil.get_impact(word, use_cvss_terms: false))
    end

    ['low', 'cat iii', 'cat   iii', 'CATEGORY III', 'cat 3'].each do |word|
      assert_equal(0.3, Utils::InspecUtil.get_impact(word, use_cvss_terms: false))
    end

    ['medium', 'med', 'cat ii', 'cat   ii', 'CATEGORY II', 'cat 2'].each do |word|
      assert_equal(0.5, Utils::InspecUtil.get_impact(word, use_cvss_terms: false))
    end

    ['high', 'cat i', 'cat   i', 'CATEGORY I', 'cat 1'].each do |word|
      assert_equal(0.7, Utils::InspecUtil.get_impact(word, use_cvss_terms: false))
    end

    ['critical', 'crit', 'severe'].each do |word|
      assert_equal(1.0, Utils::InspecUtil.get_impact(word, use_cvss_terms: false))
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
    assert_equal(0.0, Utils::InspecUtil.get_impact(0.01, use_cvss_terms: false))
    assert_equal(0.3, Utils::InspecUtil.get_impact(0.1, use_cvss_terms: false))
    assert_equal(0.3, Utils::InspecUtil.get_impact(0.2, use_cvss_terms: false))
    assert_equal(0.3, Utils::InspecUtil.get_impact(0.3, use_cvss_terms: false))
    assert_equal(0.5, Utils::InspecUtil.get_impact(0.4, use_cvss_terms: false))
    assert_equal(0.5, Utils::InspecUtil.get_impact(0.5, use_cvss_terms: false))
    assert_equal(0.5, Utils::InspecUtil.get_impact(0.6, use_cvss_terms: false))
    assert_equal(0.7, Utils::InspecUtil.get_impact(0.7, use_cvss_terms: false))
    assert_equal(0.7, Utils::InspecUtil.get_impact(0.8, use_cvss_terms: false))
    assert_equal(1.0, Utils::InspecUtil.get_impact(0.9, use_cvss_terms: false))
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
    assert_equal('none', Utils::InspecUtil.get_impact_string(0, use_cvss_terms: false))
    assert_equal('none', Utils::InspecUtil.get_impact_string(0.01, use_cvss_terms: false))
    assert_equal('low', Utils::InspecUtil.get_impact_string(0.1, use_cvss_terms: false))
    assert_equal('low', Utils::InspecUtil.get_impact_string(0.2, use_cvss_terms: false))
    assert_equal('low', Utils::InspecUtil.get_impact_string(0.3, use_cvss_terms: false))
    assert_equal('medium', Utils::InspecUtil.get_impact_string(0.4, use_cvss_terms: false))
    assert_equal('medium' ,Utils::InspecUtil.get_impact_string(0.5, use_cvss_terms: false))
    assert_equal('medium', Utils::InspecUtil.get_impact_string(0.6, use_cvss_terms: false))
    assert_equal('high', Utils::InspecUtil.get_impact_string(0.7, use_cvss_terms: false))
    assert_equal('high', Utils::InspecUtil.get_impact_string(0.8, use_cvss_terms: false))
    assert_equal('critical', Utils::InspecUtil.get_impact_string(0.9, use_cvss_terms: false))
    assert_equal('critical', Utils::InspecUtil.get_impact_string(1.0, use_cvss_terms: false))
    assert_equal('critical', Utils::InspecUtil.get_impact_string(1, use_cvss_terms: false))
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
    assert_equal('Use human readable security markings', ckl_json[:"V-26680"][:rule_title])
    assert_equal('AC-16 (5) Rev_4', ckl_json[:"V-26680"][:nist])
  end

  describe '#generate_controls' do
    let(:subject) { Utils::InspecUtil.generate_controls(json) }
    let(:json) do
      {
        'profiles' => [{ 'controls' => controls }]
      }
    end
    let(:controls) do
      [
        {
          'id' => '1',
            'tags' => {}
        },
      ]
    end

    describe 'when generating a control profile' do
      it 'sets fixref tag' do

      end
    end
  end

  describe '#parse_data_for_xccdf' do # rubocop:disable Metrics/BlockLength
    let(:subject) { Utils::InspecUtil.parse_data_for_xccdf(json) }
    let(:json) do
      {
        'profiles' => [{ 'controls' => controls }]
      }
    end
    let(:controls) do
      [
        {
          'id' => '1',
            'tags' => {}
        },
      ]
    end

    describe 'when parsing the single control profile' do
      let(:json) { JSON.parse(File.read('./examples/sample_json/single_control_profile.json')) }

      it 'parses as expected' do
        assert_equal('Users must re-authenticate for privilege escalation.', subject['controls'][0]['title'])
        assert_equal('F-78301r2_fix', subject['controls'][0]['fix_id'])
      end
    end

    describe 'when there is no cci' do
      it 'does not set a value' do
        assert_equal false, subject['controls'].first.key?('cci')
      end
    end

    describe 'when there is no fix' do
      it 'does not set a value' do
        assert_equal true, subject['controls'].first.key?('fix')
      end
    end

    describe 'when there is no fix_id' do
      it 'does not set a value' do
        assert_equal false, subject['controls'].first.key?('fix_id')
      end
    end

    describe 'when there is no gdescription' do
      it 'does not set a value' do
        assert_equal false, subject['controls'].first.key?('gdescription')
      end
    end

    describe 'when there is no gid' do
      let(:controls) do
        [
          {
            'id' => '1',
              'tags' => {}
          },
        ]
      end

      it 'defaults a value that is control id' do
        assert_equal controls.first['id'], subject['controls'].first['gid']
      end
    end

    describe 'when there is no gtitle' do
      it 'does not set a value' do
        assert_equal false, subject['controls'].first.key?('gtitle')
      end
    end

    describe 'when there is no rid' do
      let(:controls) do
        [
          {
            'id' => '1',
              'tags' => { 'gid' => 'g_id_1' }
          },
        ]
      end

      it 'defaults a value that is r_ + the gid value' do
        assert_equal "r_#{controls.first['tags']['gid']}", subject['controls'].first['rid']
      end
    end

    describe 'when there is no rversion' do
      it 'does not set a value' do
        assert_equal false, subject['controls'].first.key?('rversion')
      end
    end

    describe 'when there is no rweight' do
      it 'does not set a value' do
        assert_equal false, subject['controls'].first.key?('rweight')
      end
    end

    describe 'when there is no severity' do
      it 'defaults to the value unknown' do
        assert_equal 'unknown', subject['controls'].first['severity']
      end
    end

    describe 'when there is no title' do
      it 'does not set a value' do
        assert_equal false, subject['controls'].first.key?('title')
      end
    end
  end
end
