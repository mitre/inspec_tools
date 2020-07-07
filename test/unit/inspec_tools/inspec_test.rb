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

describe 'InspecTools::Inspec' do # rubocop:disable Metrics/BlockLength
  let(:dci) { InspecTools::Inspec.new(inspec_json) }
  let(:inspec_json) { File.read('examples/sample_json/single_control_profile.json') }

  describe '#populate_header' do
    let(:dci) do
      InspecTools::Inspec.new(inspec_json).tap { |i| i.to_xccdf(attributes) }
    end
    let(:subject) { dci.send(:populate_header) }
    let(:attributes) { {} }

    describe 'when attribute benchmark.notice.id is not provided' do
      it 'does not include notice on the benchmark' do
        subject
        benchmark = dci.instance_variable_get(:@benchmark)
        assert_nil benchmark.notice
      end
    end

    describe 'when attribute benchmark.plaintext and benchmark.plaintext.id are not provided' do
      it 'does not include notice on the benchmark' do
        subject
        benchmark = dci.instance_variable_get(:@benchmark)
        assert_nil benchmark.plaintext
      end
    end
  end

  describe '#populate_groups' do # rubocop:disable Metrics/BlockLength
    let(:dci) { InspecTools::Inspec.new(inspec_json).tap { |i| i.to_xccdf(attributes) } }
    let(:subject) { dci.send(:populate_header) }
    let(:attributes) { {} }
    let(:inspec_json) do
      {
        'profiles' => [{ 'controls' => controls }]
      }.to_json
    end
    let(:controls) do
      [
        {
          'id' => '1',
            'tags' => {}
        },
      ]
    end

    describe 'when attribute content_ref.name and content_ref.href are not provided' do
      it 'does not include Group::Rule::check::check-content-ref on the benchmark' do
        subject
        benchmark = dci.instance_variable_get(:@benchmark)
        assert_nil benchmark.group.first.rule.check.content_ref
      end
    end

    describe 'when tag cci is not provided' do
      it 'does not include Group::Rule::ident on the benchmark' do
        subject
        benchmark = dci.instance_variable_get(:@benchmark)
        assert_nil benchmark.group.first.rule.ident
      end
    end

    describe 'when tag fixref is not provided' do
      it 'does not include Group::Rule::fix on the benchmark' do
        subject
        benchmark = dci.instance_variable_get(:@benchmark)
        assert_nil benchmark.group.first.rule.fix
      end
    end

    describe 'when tag gdescription is not provided' do
      it 'does not include Group::description on the benchmark' do
        subject
        benchmark = dci.instance_variable_get(:@benchmark)
        assert_nil benchmark.group.first.description
      end
    end

    describe 'when tag gdescription is provided' do
      let(:controls) do
        [
          {
            'id' => '1',
              'tags' => { 'gdescription' => 'A test description' }
          },
        ]
      end

      it 'wraps the data in <GroupDescription> XML tags' do
        subject
        benchmark = dci.instance_variable_get(:@benchmark)
        assert_equal "<GroupDescription>#{controls.first['tags']['gdescription']}</GroupDescription>", benchmark.group.first.description
      end
    end

    describe 'when no reference attributes are provided' do
      it 'does not include Group::Rule::fix on the benchmark' do
        subject
        benchmark = dci.instance_variable_get(:@benchmark)
        assert_nil benchmark.group.first.rule.reference
      end
    end
  end
end
