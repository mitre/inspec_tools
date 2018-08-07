#!/usr/bin/env ruby

# author: Aaron Lippold
# author: Rony Xavier rx294@nyu.edu
# author: Matthew Dromazos

require 'thor'
require 'nokogiri'
require_relative 'version'

class MyCLI < Thor
  
  desc 'xccdf2inspec', 'xccdf2inspec translates an xccdf file to an inspec profile'
  option :xccdf, required: true, aliases: '-x'
  option :cci, require: true, aliases: '-c'
  option :output, required: false, aliases: '-o'
  option :format, required: false, aliases: '-f'
  option :seperate_files, required: false, aliases: '-s'
  option :replace_tags, require: false, aliases: '-r'
  def xccdf2inspec
    profile = InspecTools::XCCDF.new(options[:xccdf]))
    Utils::InspecUtil.unpack_inspec_json(options[:output], profile, options[:seperated_files], options[:format])
    Xccdf2Inspec.new(options[:xccdf], options[:cci], options[:output], options[:format], options[:seperate_files], options[:replace_tags])
  end
  
  desc 'inspec2xccdf', 'Inspec2xccdf convertes an Inspec profile into STIG XCCDF Document'
  option :inspec_json, required: true, aliases: '-j'
  option :attributes, required: true, aliases: '-a'
  option :xccdf_title, required: true, aliases: '-t'
  option :verbose, type: :boolean, aliases: '-V'
  def inspec2xccdf
    Inspec2xccdf.new(options[:inspec_json], options[:attributes], options[:xccdf_title], options[:verbose])
  end
  
  desc 'inspec2ckl', 'Inspec2ckl translates Inspec results json to Stig Checklist'
  option :inspec_json, required: true, aliases: '-j'
  option :cklist, required: false, aliases: '-c'
  option :title, required: false, aliases: '-t'
  option :date, required: false, aliases: '-d'
  option :attrib, required: false, aliases: '-a'
  option :output, required: true, aliases: '-o'
  option :verbose, type: :boolean, aliases: '-V'
  def inspec2ckl
    attrib = YAML.load_file(options[:attrib]) unless options[:attrib].nil? || !File.file?(options[:attrib])
    attrib = {} unless attrib
    title = options[:title] || attrib['title']
    date = options[:date] || attrib['date']
    Inspec2ckl.new(options[:inspec_json], options[:cklist], title, date, options[:output], options[:verbose])
  end




  # map %w[--help -h] => :help
  # desc 'help', 'Help for using Inspec2ckl'
  # def help
  #   puts "\nXCCDF2Inspec translates an xccdf file to an inspec profile\n\n"
  #   puts "\t-x --xccdf : Path to the disa stig xccdf file"
  #   puts "\t-c --cci : Path to the cci xml file"
  #   puts "\t-o --output : The name of the inspec file you want"
  #   puts "\t-f --format [ruby | hash] : The format you would like (defualt: ruby)"
  #   puts "\t-s --seperate-files [true | false] : Output the resulting controls as one or mutlple files (defualt: true)"
  #   puts "\t-r --replace-tags array (case sensitive): A comma seperated list to replace tags with a $ if found in a group rules description tag"
  #   puts "\nexample: ./xccdf2inspec exec -c cci_list.xml -x xccdf_file.xml -o myprofile -f ruby \n\n"
  # end

  # map %w[--version -v] => :print_version
  # desc '--version, -v', "print's inspec2ckl version"
  # def print_version
  #   puts XCCDF2InSpec::VERSION
  # end
end

MyCLI.start(ARGV)
