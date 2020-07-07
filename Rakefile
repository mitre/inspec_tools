require "bundler/gem_tasks"
require "rake/testtask"
require File.expand_path('../lib/inspec_tools/version', __FILE__)

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
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

  # Excluding all tests that take more than 3 seconds to complete
  Rake::TestTask.new(:exclude_slow) do |t|
    t.libs << 'test'
    t.libs << "lib"
    t.verbose = true
    t.test_files = FileList['test/**/*_test.rb'].reject{|file| file.include? 'pdf_test.rb'}.reverse
  end
end 

desc 'Build and publish the gem'
task publish: :build do
  system("gem push pkg/inspec_tools-#{InspecTools::VERSION}.gem")
end

task :default => :test
