# encoding: utf-8

libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'inspec2ckl/inspec2ckl'
require 'inspec2ckl/StigChecklist'
require 'inspec2ckl/version'
