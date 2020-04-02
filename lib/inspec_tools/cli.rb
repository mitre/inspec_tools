require 'yaml'
require 'json'

require 'inspec-objects'
require 'inspec'
require_relative 'version'

require_relative '../utilities/inspec_util'
require_relative '../utilities/csv_util'
require_relative './plugin_cli.rb'

# This tells the ruby cli app to use the same argument parsing as the plugin
module InspecTools
  CLI = InspecPlugins::InspecToolsPlugin::CliCommand
end

#=====================================================================#
#                        Pre-Flight Code
#=====================================================================#
help_commands = ['-h', '--help', 'help']
log_commands = ['-l', '--log-directory']
version_commands = ['-v', '--version', 'version']

#---------------------------------------------------------------------#
# Adjustments for non-required version commands
#---------------------------------------------------------------------#
unless (version_commands & ARGV).empty?
  puts InspecTools::VERSION
  exit 0
end

#---------------------------------------------------------------------#
# Adjustments for non-required log-directory
#---------------------------------------------------------------------#
ARGV.push("--log-directory=#{Dir.pwd}/logs") if (log_commands & ARGV).empty? && (help_commands & ARGV).empty?
