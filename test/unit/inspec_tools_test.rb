require_relative 'test_helper'
require 'inspec'

class InspecToolsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::InspecTools::VERSION
  end
end
