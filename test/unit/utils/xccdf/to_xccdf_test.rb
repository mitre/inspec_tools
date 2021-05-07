require_relative '../../test_helper'
require_relative '../../../../lib/utilities/xccdf/to_xccdf'
require_relative '../../../../lib/happy_mapper_tools/benchmark'

describe Utils::ToXCCDF do
  let(:dci) { Utils::ToXCCDF.new(attributes, inspec_data) }
  let(:attributes) { {} }
  let(:inspec_data) do
    { 'controls' => controls }
  end

  let(:controls) do
    [
      {
        'results' => [
          {
            'run_time' => 0.000101,
            'start_time' => '2019-10-17T08:00:02-04:00'
          },
        ]
      },
      {
        'results' => [
          {
            'run_time' => 2.426861,
            'start_time' => '2019-10-17T08:00:04-04:00'
          },
          {
            'run_time' => 2.0e-06,
            'start_time' => '2019-10-17T08:00:02-04:00'
          },

        ]
      },
    ]
  end

  describe '#run_end_time' do
    it 'returns the latest time of all results' do
      assert_equal '2019-10-17T08:00:06-04:00', dci.send(:run_end_time).to_s
    end
  end

  describe '#run_start_time' do
    it 'returns the earliest start time of all results' do
      assert_equal '2019-10-17T08:00:02-04:00', dci.send(:run_start_time).to_s
    end
  end

  describe '#build_benchmark_header' do
    let(:subject) { dci.send(:build_benchmark_header) }
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

  describe '#build_groups' do
    let(:subject) { dci.send(:build_groups) }
    let(:attributes) { {} }
    let(:controls) do
      [
        {
          'id' => '1',
          'desc' => 'A description'
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
            'gdescription' => 'A test description',
            'desc' => 'A description'
          },
        ]
      end

      it 'wraps the data in <GroupDescription> XML tags' do
        subject
        benchmark = dci.instance_variable_get(:@benchmark)
        assert_equal "<GroupDescription>#{controls.first['gdescription']}</GroupDescription>", benchmark.group.first.description
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

  describe '#populate_target_facts' do
    let(:subject) { dci.send(:populate_target_facts, benchmark_test_result, metadata) }
    let(:benchmark_test_result) { HappyMapperTools::Benchmark::TestResult.new }
    let(:metadata) { {} }

    describe 'when no facts are provided' do
      it 'does not create the target_facts element' do
        subject
        assert_nil benchmark_test_result.target_facts
      end
    end

    describe 'when a mac address is defined' do
      let(:metadata) { { 'mac' => '00:11:00' } }

      it 'sets a fact' do
        subject
        assert_equal '00:11:00', benchmark_test_result.target_facts.fact.first.fact
      end
    end

    describe 'when a ipv4 address is defined' do
      let(:metadata) { { 'ip' => '192.168.0.1' } }

      it 'sets a fact' do
        subject
        assert_equal '192.168.0.1', benchmark_test_result.target_facts.fact.first.fact
      end
    end

    describe 'when a target address is defined' do
      let(:metadata) { { 'ip' => '192.168.0.1' } }

      it 'sets a target' do
        subject
        assert_equal '192.168.0.1', benchmark_test_result.target_address
      end
    end

    describe 'when a target is defined' do
      let(:metadata) { { 'fqdn' => 'some.host.local' } }

      it 'sets a target' do
        subject
        assert_equal 'some.host.local', benchmark_test_result.target
      end
    end
  end

  describe '#populate_results' do
    let(:subject) { dci.send(:populate_results, benchmark_test_result) }
    let(:benchmark_test_result) { HappyMapperTools::Benchmark::TestResult.new }
    describe 'when there is more than one test result for a control' do
      let(:controls) do
        [
          {
            'results' => [
              {
                'run_time' => 2.426861,
                'start_time' => '2019-10-17T08:00:04-04:00',
                'status' => 'failed',
                'code_desc' => 'File 1 should exist',
                'cci' => %w{ident_1 ident_2},
                'message' => 'Can\'t find file: 1'
              },
              {
                'run_time' => 2.0e-06,
                'start_time' => '2019-10-17T08:00:02-04:00',
                'status' => 'failed',
                'code_desc' => 'File 2 should exist',
                'cci' => %w{ident_1 ident_2},
                'message' => 'Can\'t find file: 2'
              },
              {
                'run_time' => 2.0e-06,
                'start_time' => '2019-10-17T08:00:02-04:00',
                'status' => 'passed'
              },
            ]
          },
        ]
      end

      it 'consolidates the values into a single rule-result value' do
        subject
        assert_equal 1, benchmark_test_result.rule_result.size
        assert_equal 'fail', benchmark_test_result.rule_result.first.result
      end
    end
  end

  describe '#result_message' do
    let(:subject) { dci.send(:result_message, result, xccdf_status) }
    let(:xccdf_status) { 'pass' }

    describe 'when there is no message information' do
      let(:result) { {} }

      it 'returns nil' do
        assert_nil subject
      end
    end

    describe 'when there is message information' do
      let(:xccdf_status) { 'fail' }
      let(:result) do
        {
          'status' => 'failed',
          'code_desc' => 'System Package firewalld should be installed',
          'message' => 'expected that `System Package firewalld` is installed'
        }
      end

      it 'returns a message' do
        message = subject
        assert_equal "System Package firewalld should be installed\n\nexpected that `System Package firewalld` is installed", message.message
        assert_equal 'error', message.severity
      end
    end
  end

  describe '#populate_identity' do
    let(:subject) { dci.send(:populate_identity, benchmark_test_result, metadata) }
    let(:benchmark_test_result) { HappyMapperTools::Benchmark::TestResult.new }
    let(:metadata) { {} }

    describe 'when test_result.identity.identity is provided' do
      let(:metadata) { { 'identity' => { 'identity' => 'some_user', 'privileged' => true } } }

      it 'sets the identity information' do
        subject
        assert benchmark_test_result.identity.authenticated
        assert_equal 'some_user', benchmark_test_result.identity.identity
        assert benchmark_test_result.identity.privileged
      end
    end

    describe 'when test_result.organization is provided' do
      let(:metadata) { { 'organization' => 'MITRE Corporation' } }

      it 'sets the organization' do
        subject
        assert_equal 'MITRE Corporation', benchmark_test_result.organization
      end
    end
  end
end
