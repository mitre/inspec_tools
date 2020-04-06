require_relative '../test_helper'
require 'roo'
require 'yaml'

class XLSXToolTest < Minitest::Test
  def setup
    @xlsx = Roo::Spreadsheet.open('examples/cis.xlsx')
    @mapping = YAML.load_file('examples/xlsx2inspec/mapping.cis.yml')
  end

  def test_that_xlsx_exists
    refute_nil ::InspecTools::XLSXTool
  end

  def test_to_inspec
    xlsx = InspecTools::XLSXTool.new(@xlsx, @mapping, 'test')
    profile = xlsx.to_inspec('test')
    assert_equal profile['name'], 'test'
    assert_equal profile['generator'][:version], ::InspecTools::VERSION
    assert_equal profile['controls'].first['tags']['nist'], ["IA-2 (1)", "Rev_4"]
    assert_equal profile['controls'].first['tags']['cis_controls'], ["4.5", "Rev_7"]
  end
end
