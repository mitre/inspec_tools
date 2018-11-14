require_relative '../test_helper'
require 'csv'

class CSVTest < Minitest::Test
  def test_that_csv_exists
    refute_nil ::InspecTools::CSVTool
  end

  def test_csv_init_with_valid_params
    csv = CSV.read('examples/csv2inspec/stig.csv', encoding: 'ISO8859-1')
    mapping = YAML.load_file('examples/csv2inspec/mapping.yml')
    assert(InspecTools::CSVTool.new(csv, mapping, 'test', false))
  end

  def test_csv_init_with_invalid_params
    csv = nil
    mapping = nil
    assert_raises(StandardError) { InspecTools::CSVTool.new(csv, mapping, 'test', false) }
  end

  def test_csv_to_inspec
    csv = CSV.read('examples/csv2inspec/stig.csv', encoding: 'ISO8859-1')
    mapping = YAML.load_file('examples/csv2inspec/mapping.yml')
    csv_tool = InspecTools::CSVTool.new(csv, mapping, 'test', false)
    inspec_json = csv_tool.to_inspec
    assert(inspec_json)
  end
end
