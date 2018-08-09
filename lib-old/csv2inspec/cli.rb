#!/usr/bin/env ruby
# encoding: utf-8
# author: Aaron Lippold
# author: Rony Xavier rx294@nyu.edu

require 'thor'
require_relative 'version'
require_relative 'csv2inspec'

# DTD_PATH = "checklist.dtd"

module InspecTo
  class MyCLI < Thor
    desc 'exec', 'csv2inspec translates CSV to Inspec controls'
    option :csv, required: true, aliases: '-c'
    option :mapping, required: true, aliases: '-m'
    option :verbose, type: :boolean, aliases: '-V'
    def exec
      Csv2Inspec.new(options[:csv], options[:mapping], options[:verbose])
    end
  
    desc 'generate_map', 'Generates mapping template from CSV to Inspec Controls'
    def generate_map
      template = %q(
      # Setting csv_header to true will skip the csv file header
      skip_csv_header: true
      width   : 80
  
  
      control.id: 0
      control.title: 15
      control.desc: 16
      control.tags:
              severity: 1
              rid: 8
              stig_id: 3
              cci: 2
              check: 12
              fix: 10
      )
      myfile = File.new('mapping.yml', 'w')
      myfile.puts template
      myfile.close
    end
  
    map %w{--help -h} => :help
    desc 'help', 'Help for using csv2inspec'
    def help
      puts "\tcsv2inspec translates CSV to Inspec controls\n\n"
      puts "\t-c --csv : Path to DISA Stig style csv"
      puts "\t-m --mapping : Path to yaml with mapping from CSV to Inspec Controls"
      puts "\t-V --verbose : verbose run"
      puts "\nexample: ./csv2inspec exec -c stig.csv -m mapping.yml\n\n"
      puts "\nexample: './csv2inspec generate_map' to generate mapping template\n\n"
    end
  
    map %w{--version -v} => :print_version
    desc '--version, -v', "print's csv2inspec version"
    def print_version
      puts Csv2inspec::VERSION
    end
  end
end

