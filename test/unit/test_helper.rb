require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
root = File.expand_path("../../", File.dirname(__FILE__))
require "#{root}/lib/inspec_tools"
