# encoding: utf-8

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'xccdf2inspec/xccdf2inspec'
require 'xccdf2inspec/CCIAttributes'
require 'xccdf2inspec/StigAttributes'
require 'xccdf2inspec/version'
