require 'rake/testtask'
require File.expand_path('../lib/inspec_tools/version', __FILE__)

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

namespace :test do
  Rake::TestTask.new(:windows) do |t|
    t.libs << 'test'
    t.libs << "lib"
    t.test_files = Dir.glob([
      'test/unit/inspec_tools/csv_test.rb',
      'test/unit/inspec_tools/inspec_test.rb',
      'test/unit/inspec_tools/xccdf_test.rb',
      'test/unit/utils/inspec_util_test.rb',
      'test/unit/inspec_tools_test.rb'
    ])
  end
end

desc 'Build for release'
task :build_release do

  Rake::Task["generate_mapping_objects"].reenable
  Rake::Task["generate_mapping_objects"].invoke

  system('gem build inspec_tools.gemspec')
end

desc 'Generate mapping objects'
task :generate_mapping_objects do
  require 'roo'

  nist_mapping_cis_controls = ENV['NIST_MAPPING_CIS_CONTROLS'] || 'NIST_Map_02052020_CIS_Controls_Version_7.1_Implementation_Groups_1.2.xlsx'.freeze
  nist_mapping_cis_critical_controls = ENV['NIST_MAPPING_CIS_CRITICAL_CONTROLS'] || 'NIST_Map_09212017B_CSC-CIS_Critical_Security_Controls_VER_6.1_Excel_9.1.2016.xlsx'.freeze

  data_root_path = File.join(File.expand_path(__dir__), 'lib', 'data')
  cis_controls_path = File.join(data_root_path, nist_mapping_cis_controls)
  cis_critical_controls_path = File.join(data_root_path, nist_mapping_cis_critical_controls)

  raise "#{cis_controls_path} does not exist" unless File.exist?(cis_controls_path)

  raise "#{cis_critical_controls_path} does not exist" unless File.exist?(cis_critical_controls_path)

  marshal_cis_controls(cis_controls_path, data_root_path)
  marshal_cis_critical_controls(cis_critical_controls_path, data_root_path)
end

def marshal_cis_controls(cis_controls_path, data_root_path)
  cis_to_nist = {}
  Roo::Spreadsheet.open(cis_controls_path).sheet(3).each do |row|
    if row[3].is_a?(Numeric)
      cis_to_nist[row[3].to_s] = row[0]
    else
      cis_to_nist[row[2].to_s] = row[0] unless (row[2] == '') || row[2].to_i.nil?
    end
  end
  output_file = File.new(File.join(data_root_path, 'cis_to_nist_mapping'), 'w')
  Marshal.dump(cis_to_nist, output_file)
  output_file.close
end

def marshal_cis_critical_controls(cis_critical_controls_path, data_root_path)
  controls_spreadsheet = Roo::Spreadsheet.open(cis_critical_controls_path)
  controls_spreadsheet.default_sheet = 'VER 6.1 Controls'
  headings = {}
  controls_spreadsheet.row(3).each_with_index { |header, idx| headings[header] = idx }

  nist_ver = 4
  cis_ver = controls_spreadsheet.row(2)[4].split(' ')[-1]
  control_count = 1
  mapping = []
  ((controls_spreadsheet.first_row + 3)..controls_spreadsheet.last_row).each do |row_value|
    current_row = {}
    if controls_spreadsheet.row(row_value)[headings['NIST SP 800-53 Control #']].to_s != ''
      current_row[:nist] = controls_spreadsheet.row(row_value)[headings['NIST SP 800-53 Control #']].to_s
    else
      current_row[:nist] = 'Not Mapped'
    end
    current_row[:nist_ver] = nist_ver
    if controls_spreadsheet.row(row_value)[headings['Control']].to_s == ''
      current_row[:cis] = control_count.to_s
      control_count += 1
    else
      current_row[:cis] = controls_spreadsheet.row(row_value)[headings['Control']].to_s
    end
    current_row[:cis_ver] = cis_ver
    mapping << current_row
  end
  output_file = File.new(File.join(data_root_path, 'cis_to_nist_critical_controls'), 'w')
  Marshal.dump(mapping, output_file)
  output_file.close
end
