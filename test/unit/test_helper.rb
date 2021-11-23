require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require 'inspec_tools'

require 'minitest/reporters'

reporter_options = { color: true, slow_count: 5 }
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new(reporter_options)]

# Populate stdin with the specified number of 'y' characters
def test_populate_stdin(number)
  string_io = StringIO.new
  number.times do
    string_io.puts 'y'
  end
  string_io.rewind

  $stdin = string_io

  yield

  $stdin = STDIN
end
