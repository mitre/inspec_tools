require_relative '../../test_helper'
require_relative '../../../../lib/utilities/xccdf/from_inspec'

describe Utils::FromInspec do
  let(:dci) { Utils::FromInspec.new }

  describe '#parse_data_for_xccdf' do
    let(:subject) { dci.parse_data_for_xccdf(json) }
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
        refute subject['controls'].first.key?('cci')
      end
    end

    describe 'when there is no fix' do
      it 'does not set a value' do
        assert subject['controls'].first.key?('fix')
      end
    end

    describe 'when there is no fix_id' do
      it 'does not set a value' do
        refute subject['controls'].first.key?('fix_id')
      end
    end

    describe 'when there is no gdescription' do
      it 'does not set a value' do
        refute subject['controls'].first.key?('gdescription')
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
        refute subject['controls'].first.key?('gtitle')
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
        refute subject['controls'].first.key?('rversion')
      end
    end

    describe 'when there is no rweight' do
      it 'does not set a value' do
        refute subject['controls'].first.key?('rweight')
      end
    end

    describe 'when there is no severity' do
      it 'defaults to the value unknown' do
        assert_equal 'unknown', subject['controls'].first['severity']
      end
    end

    describe 'when there is no title' do
      it 'does not set a value' do
        refute subject['controls'].first.key?('title')
      end
    end
  end
end
