require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require 'inspec_tools'

require 'minitest/reporters'

reporter_options = { color: true, slow_count: 5 }
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(reporter_options)]
