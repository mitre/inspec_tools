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
end

describe InspecTools::Inspec do
  let(:dci) { InspecTools::Inspec.new(inspec_json) }
  let(:inspec_json) do
    {
      'profiles' => [{ 'controls' => controls }]
    }.to_json
  end
  let(:controls) do
    [{ 'id': 'V-221652' }]
  end

  describe '#generate_ckl' do
    let(:subject) { dci.send(:generate_ckl, attributes) }
    let(:attributes) { {} }
    let(:checklist) { HappyMapperTools::StigChecklist::Checklist.new }

    before do
      dci.instance_variable_set(:@data, {})
      dci.instance_variable_set(:@checklist, checklist)
      dci.instance_variable_set(:@platform, nil)
    end

    describe 'when a benchmark version is available' do
      let(:attributes) { { 'benchmark.version' => 2 } }

      it 'sets the SI_DATA version' do
        subject
        data = checklist.stig.istig.stig_info.si_data.find { |d| d.name == 'version' }
        assert_equal data.data, 2
      end
    end

    describe 'when a benchmark plaintext is available' do
      let(:attributes) { { 'benchmark.plaintext' => 'Release 2020' } }

      it 'sets the SI_DATA releaseinfo' do
        subject
        data = checklist.stig.istig.stig_info.si_data.find { |d| d.name == 'releaseinfo' }
        assert_equal data.data, 'Release 2020'
      end
    end

    describe 'when a benchmark title is available' do
      let(:attributes) { { 'benchmark.title' => 'STIG Testing' } }

      it 'sets the SI_DATA releaseinfo' do
        subject
        data = checklist.stig.istig.stig_info.si_data.find { |d| d.name == 'title' }
        assert_equal data.data, 'STIG Testing'
      end
    end
  end

  describe '#generate_title' do
    let(:subject) { dci.send(:generate_title, attributes, inspec_json) }
    let(:attributes) { {} }
    let(:checklist) { HappyMapperTools::StigChecklist::Checklist.new }

    before do
      dci.instance_variable_set(:@data, {})
      dci.instance_variable_set(:@checklist, checklist)
      dci.instance_variable_set(:@platform, nil)
    end

    describe 'when a benchmark.title attribute is provided' do
      let(:attributes) do
        {
          'benchmark.plaintext' => 'Release 2020',
          'benchmark.title' => 'STIG Testing',
          'benchmark.version' => 2
        }
      end

      it 'creates the title from attribute data' do
        assert_equal subject, 'STIG Testing :: Version 2, Release 2020'
      end
    end
  end
end
