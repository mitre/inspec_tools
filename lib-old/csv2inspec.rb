# encoding: utf-8

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'csv2inspec/csv2inspec'
require 'csv2inspec/version'
