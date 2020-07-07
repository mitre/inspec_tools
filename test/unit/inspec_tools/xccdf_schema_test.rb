require 'open3'
require_relative '../test_helper'

describe 'Validate conformant XCCDF' do
  let(:xccdf_attributes) { JSON.parse(File.read('examples/attribute.json')) }
  let(:inspec_json) { File.read('examples/sample_json/single_control_results.json') }
  let(:inspec_tools) { InspecTools::Inspec.new(inspec_json) }
  let(:schema_file) { 'test/schemas/xccdf_114/xccdf-1.1.4.xsd' }

  describe 'when XCCDF version is 1.1 and conformant' do
    let(:xccdf_attributes) { JSON.parse(File.read('examples/inspec2xccdf/xccdf_compliant_attribute.json')) }

    it 'produces XML that is valid' do
      xccdf = inspec_tools.to_xccdf(xccdf_attributes)
      _stdout, status = Open3.capture2e("echo '#{xccdf}' | xmllint --schema #{Shellwords.escape(File.expand_path(schema_file))} --nowarning -")
      assert_equal 0, status.exitstatus
    end
  end

  describe 'when XCCDF version is 1.1 and nonconformant' do
    it 'produces XML that is invalid' do
      xccdf = inspec_tools.to_xccdf(xccdf_attributes)
      _stdout, status = Open3.capture2e("echo '#{xccdf}' | xmllint --schema #{Shellwords.escape(File.expand_path(schema_file))} --noout --nowarning -")
      assert_equal 3, status.exitstatus
    end
  end
end
