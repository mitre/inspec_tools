require_relative '../test_helper'
require 'json'

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

  def test_to_xccdf_single_control
    profile = File.read('./examples/sample_json/single_control_profile.json')
    json = JSON.parse(profile)
    inspec_converter = InspecTools::Inspec.new(profile)
    subject = inspec_converter.send(:parse_data_for_xccdf, json)
    assert_equal('Users must re-authenticate for privilege escalation.', subject['controls'][0]['title'])
    assert_equal('F-78301r2_fix', subject['controls'][0]['fix_id'])
    assert_match(/Verify the operating system requires users to reauthenticate/, subject['controls'][0]['check'])
    assert_match(/Configure the operating system to require users to reauthenticate/, subject['controls'][0]['fix'])
  end

  def test_to_xccdf_no_value_when_no_cci
    json = {
      'profiles' => [
        { 'controls' => [
          {
            'id' => '1',
            'tags' => {},
            'descriptions' => {}
          },
        ] },
      ]
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    subject = inspec_converter.send(:parse_data_for_xccdf, json)
    refute subject['controls'].first.key?('cci')
  end

  def test_to_xccdf_no_value_when_no_fix
    json = {
      'profiles' => [
        { 'controls' => [
          {
            'id' => '1',
            'tags' => {},
            'descriptions' => {}
          },
        ] },
      ]
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    subject = inspec_converter.send(:parse_data_for_xccdf, json)
    assert subject['controls'].first.key?('fix')
  end

  def test_to_xccdf_no_value_when_no_fix_id
    json = {
      'profiles' => [
        { 'controls' => [
          {
            'id' => '1',
            'tags' => {},
            'descriptions' => {}
          },
        ] },
      ]
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    subject = inspec_converter.send(:parse_data_for_xccdf, json)
    refute subject['controls'].first.key?('fix_id')
  end

  def test_to_xccdf_no_value_when_no_gdescription
    json = {
      'profiles' => [
        { 'controls' => [
          {
            'id' => '1',
            'tags' => {},
            'descriptions' => {}
          },
        ] },
      ]
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    subject = inspec_converter.send(:parse_data_for_xccdf, json)
    refute subject['controls'].first.key?('gdescription')
  end

  def test_to_xccdf_no_value_when_no_gtitle
    json = {
      'profiles' => [
        { 'controls' => [
          {
            'id' => '1',
            'tags' => {},
            'descriptions' => {}
          },
        ] },
      ]
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    subject = inspec_converter.send(:parse_data_for_xccdf, json)
    refute subject['controls'].first.key?('gtitle')
  end

  def test_to_xccdf_no_gid_defaults_to_control_id
    json = {
      'profiles' => [
        { 'controls' => [
          {
            'id' => '1',
            'tags' => {},
            'descriptions' => {}
          },
        ] },
      ]
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    subject = inspec_converter.send(:parse_data_for_xccdf, json)
    assert_equal json['profiles'].first['controls'].first['id'], subject['controls'].first['gid']
  end

  def test__to_xccdf_no_rid_default_rid_value
    json = {
      'profiles' => [
        { 'controls' => [
          {
            'id' => '1',
            'tags' => { 'gid' => 'g_id_1' },
            'descriptions' => {}
          },
        ] },
      ]
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    subject = inspec_converter.send(:parse_data_for_xccdf, json)
    assert_equal "r_#{json['profiles'].first['controls'].first['tags']['gid']}", subject['controls'].first['rid']
  end

  def test_to_xccdf_no_value_when_no_rversion
    json = {
      'profiles' => [
        { 'controls' => [
          {
            'id' => '1',
            'tags' => {},
            'descriptions' => {}
          },
        ] },
      ]
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    subject = inspec_converter.send(:parse_data_for_xccdf, json)
    refute subject['controls'].first.key?('rversion')
  end

  def test_to_xccdf_no_value_when_no_rweight
    json = {
      'profiles' => [
        { 'controls' => [
          {
            'id' => '1',
            'tags' => {},
            'descriptions' => {}
          },
        ] },
      ]
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    subject = inspec_converter.send(:parse_data_for_xccdf, json)
    refute subject['controls'].first.key?('rweight')
  end

  def test_to_xccdf_default_value_when_no_severity
    json = {
      'profiles' => [
        { 'controls' => [
          {
            'id' => '1',
            'tags' => {},
            'descriptions' => {}
          },
        ] },
      ]
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    subject = inspec_converter.send(:parse_data_for_xccdf, json)
    assert_equal 'unknown', subject['controls'].first['severity']
  end

  def test_to_xccdf_no_value_when_no_title
    json = {
      'profiles' => [
        { 'controls' => [
          {
            'id' => '1',
            'tags' => {},
            'descriptions' => {}
          },
        ] },
      ]
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    subject = inspec_converter.send(:parse_data_for_xccdf, json)
    refute subject['controls'].first.key?('title')
  end

  def test_to_xccdf_run_end_time
    # Minimum JSON to create a converter object.
    json = {
      'profiles' => [
        { 'controls' => [
          {
            'id' => '1',
            'tags' => {},
            'descriptions' => {}
          },
        ] },
      ]
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    control = { 'controls' => [
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
    ] }
    assert_equal '2019-10-17T08:00:06-04:00', inspec_converter.send(:run_end_time, control).to_s
  end

  def test_to_xccdf_run_start_time
    # Minimum JSON to create a converter object.
    json = {
      'profiles' => [
        { 'controls' => [
          {
            'id' => '1',
            'tags' => {},
            'descriptions' => {}
          },
        ] },
      ]
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    control = { 'controls' => [
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
    ] }
    assert_equal '2019-10-17T08:00:02-04:00', inspec_converter.send(:run_start_time, control).to_s
  end

  def test_to_xccdf_build_benchmark_header
    json = { 'controls' => [
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
    ] }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    # Do not create something to parse, just set the data
    inspec_converter.instance_variable_set(:@benchmark, HappyMapperTools::Benchmark::Benchmark.new)
    inspec_converter.send(:build_benchmark_header, {})
    # when attribute benchmark.plaintext and benchmark.plaintext.id are not provided does not include notice on the benchmark
    # when attribute benchmark.notice.id is not provided does not include notice on the benchmark
    assert_nil inspec_converter.instance_variable_get(:@benchmark).notice
    assert_nil inspec_converter.instance_variable_get(:@benchmark).plaintext
  end

  def test_to_xccdf_build_groups_content_ref
    # when attribute content_ref.name and content_ref.href are not provided
    # it does not include Group::Rule::check::check-content-ref on the benchmark
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    inspec_converter.instance_variable_set(:@benchmark, HappyMapperTools::Benchmark::Benchmark.new)
    inspec_converter.send(:build_groups, {}, json)
    assert_nil inspec_converter.instance_variable_get(:@benchmark).group.first.rule.check.content_ref
  end

  def test_to_xccdf_build_groups_ident
    # when tag cci is not provided it does not include Group::Rule::ident on the benchmark
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    inspec_converter.instance_variable_set(:@benchmark, HappyMapperTools::Benchmark::Benchmark.new)
    inspec_converter.send(:build_groups, {}, json)
    assert_nil inspec_converter.instance_variable_get(:@benchmark).group.first.rule.ident
  end

  def test_to_xccdf_build_groups_fix
    # when tag fixref is not provided it does not include Group::Rule::fix on the benchmark
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    inspec_converter.instance_variable_set(:@benchmark, HappyMapperTools::Benchmark::Benchmark.new)
    inspec_converter.send(:build_groups, {}, json)
    assert_nil inspec_converter.instance_variable_get(:@benchmark).group.first.rule.fix
  end

  def test_to_xccdf_build_groups_gdescription_not_provided
    # when tag gdescription is not provided it does not include Group::description on the benchmark
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    inspec_converter.instance_variable_set(:@benchmark, HappyMapperTools::Benchmark::Benchmark.new)
    inspec_converter.send(:build_groups, {}, json)
    assert_nil inspec_converter.instance_variable_get(:@benchmark).group.first.description
  end

  def test_to_xccdf_build_groups_gdescription_provided
    # when tag gdescription is provided wraps the data in <GroupDescription> XML tags
    json = { 'controls' => [
      {
        'id' => '1',
        'gdescription' => 'A test description',
        'desc' => 'A description'
      },
    ] }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    inspec_converter.instance_variable_set(:@benchmark, HappyMapperTools::Benchmark::Benchmark.new)
    inspec_converter.send(:build_groups, {}, json)
    assert_equal "<GroupDescription>#{json['controls'].first['gdescription']}</GroupDescription>", inspec_converter.instance_variable_get(:@benchmark).group.first.description
  end

  def test_to_xccdf_build_groups_reference
    # when no reference attributes are provided it does not include Group::Rule::fix on the benchmark
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    inspec_converter.instance_variable_set(:@benchmark, HappyMapperTools::Benchmark::Benchmark.new)
    inspec_converter.send(:build_groups, {}, json)
    assert_nil inspec_converter.instance_variable_get(:@benchmark).group.first.rule.reference
  end

  def test_populate_target_facts_no_facts
    # Some json to just create the inspectools::inspec object
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    metadata = {}
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    results_benchmark = inspec_converter.send(:populate_target_facts, HappyMapperTools::Benchmark::TestResult.new, metadata)
    assert_nil results_benchmark.target_facts
  end

  def test_populate_target_facts_mac_address
    # Some json to just create the inspectools::inspec object
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    metadata = { 'mac' => '00:11:00' }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    results_benchmark = inspec_converter.send(:populate_target_facts, HappyMapperTools::Benchmark::TestResult.new, metadata)
    assert_equal '00:11:00', results_benchmark.target_facts.fact.first.fact
  end

  def test_populate_target_facts_ip_address
    # Some json to just create the inspectools::inspec object
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    metadata = { 'ip' => '192.168.0.1' }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    results_benchmark = inspec_converter.send(:populate_target_facts, HappyMapperTools::Benchmark::TestResult.new, metadata)
    assert_equal '192.168.0.1', results_benchmark.target_facts.fact.first.fact
  end

  def test_populate_target_facts_target_address
    # Some json to just create the inspectools::inspec object
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    metadata = { 'ip' => '192.168.0.1' }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    results_benchmark = inspec_converter.send(:populate_target_facts, HappyMapperTools::Benchmark::TestResult.new, metadata)
    assert_equal '192.168.0.1', results_benchmark.target_address
  end

  def test_populate_target_facts_fqdn
    # Some json to just create the inspectools::inspec object
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    metadata = { 'fqdn' => 'some.host.local' }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    results_benchmark = inspec_converter.send(:populate_target_facts, HappyMapperTools::Benchmark::TestResult.new, metadata)
    assert_equal 'some.host.local', results_benchmark.target
  end

  def test_populate_results_multiple_results
    # when there is more than one test result for a control it consolidates the values into a single rule-result value
    json = { 'controls' => [
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
    ] }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    results_benchmark = inspec_converter.send(:populate_results, HappyMapperTools::Benchmark::TestResult.new, json)
    assert_equal 1, results_benchmark.rule_result.size
    assert_equal 'fail', results_benchmark.rule_result.first.result
  end

  def test_result_message_no_information
    # Some json to just create the inspectools::inspec object
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    assert_nil inspec_converter.send(:result_message, {}, 'pass')
  end

  def test_result_message_information
    # Some json to just create the inspectools::inspec object
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    result = {
      'status' => 'failed',
      'code_desc' => 'System Package firewalld should be installed',
      'message' => 'expected that `System Package firewalld` is installed'
    }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    assert_equal "System Package firewalld should be installed\n\nexpected that `System Package firewalld` is installed", inspec_converter.send(:result_message, result, 'fail').message
    assert_equal 'error', inspec_converter.send(:result_message, result, 'fail').severity
  end

  def test_populate_identity_identity
    # Some json to just create the inspectools::inspec object
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    metadata = { 'identity' => { 'identity' => 'some_user', 'privileged' => true } }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    results_benchmark = inspec_converter.send(:populate_identity, HappyMapperTools::Benchmark::TestResult.new, metadata)
    assert results_benchmark.identity.authenticated
    assert_equal 'some_user', results_benchmark.identity.identity
    assert results_benchmark.identity.privileged
  end

  def test_populate_identity_organization
    # Some json to just create the inspectools::inspec object
    json = { 'controls' => [
      {
        'id' => '1',
        'desc' => 'A description'
      },
    ] }
    metadata = { 'organization' => 'MITRE Corporation' }
    inspec_converter = InspecTools::Inspec.new(json.to_json)
    results_benchmark = inspec_converter.send(:populate_identity, HappyMapperTools::Benchmark::TestResult.new, metadata)
    assert_equal 'MITRE Corporation', results_benchmark.organization
  end
end
