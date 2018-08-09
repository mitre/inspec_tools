# encoding: utf-8

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'inspec2xccdf/inspec2xccdf'
require 'inspec2xccdf/benchmark'
require 'inspec2xccdf/inspec_profile_parser'
require 'inspec2xccdf/version'
