$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
root = File.expand_path("../../", File.dirname(__FILE__))
require "#{root}/lib/inspec_tools"

require 'minitest/autorun'
