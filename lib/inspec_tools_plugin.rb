# frozen_string_literal: true

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'inspec_tools/version'
require 'inspec_tools/plugin'
