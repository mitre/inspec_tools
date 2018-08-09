# InspecTools

InspecTools supplies several CLI tools to convert to and from InSpec format. The Converters in version 0.2 are:

* csv2inspec
* inspec2csv
* xccdf2inspec
* inspec2xccdf
* inspec2ckl
* pdf2inspec

The Ruby API is defined in lib/inspec_to.rb

# Installation

Ensure happymapper is not installed, as it will take precedence over nokogiri-happymapper.

Add this line to your application's Gemfile:

```ruby
gem 'inspec_tools', :git => "https://github.com/aaronlippold/inspec-tools"
```

And then execute:

    $ bundle

Clone the repo and install it yourself as:

    $ gem install inspec_tools

# Usage

All of the binaries will print their `help` statements when executed without any arguments. From there it should be 

## csv2inspec 

Convert a csv export of STIG controls to an inspec profile
``` bash	
USAGE: inspec_tools csv2inspec -c a_stig.csv -m map.yml -o mydir

FLAGS:
	-c --csv            : Path to DISA Stig style csv
	-m --mapping        : Path to yaml with mapping from CSV to Inspec Controls
	-V --verbose        : verbose run [optional]
  -o --output         : path or name to output the inspec profile to
  -f --format         : format to output controls to [ruby, json]
  -s --seperate_files : seperate the controls into different files [true, false]

example: inspec_tools csv2inspec -c stig.csv -m map.yml -o mydir -f ruby -s true   # To map stig.csv to inspec via map.yml
```

## inspec2csv 

Convert an inspec json to a csv file
``` bash	
USAGE: inspec_tools inspec2csv -j inspec_profile.json -o mycsv.csv

FLAGS:
	-j --inspec_json : Path to InSpec json file
  -o --output      : path or name to output the csv file to
  -V --verbose     : Run in verbose mode

example: inspec_tools inspec2csv -j inspec_profile.json -o mycsv.csv  # To map stig.csv to inspec via map.yml
```

## xccdf2inspec

xccdf2inspec translates an xccdf file to an inspec profile in one or many files
``` bash
USAGE: inspec_tools xccdf2inxpec -x xccdf_file.xml -o myprofile -f ruby

FLAGS:
	-x --xccdf                               : Path to the disa stig xccdf file
	-o --output                              : The name of the inspec file to generate [optional]
	-f --format [ruby | hash]                : The format you would like (default: ruby) [optional]
	-s --seperate-files [true | false]       : Output the resulting controls as one or mutiple files (default: true) [optional]
	-r --replace-tags array (case sensitive) : A comma seperated list to replace tags with a $ if found in a group rules description tag [optional]  

example: inspec_tools xccdf2inxpec -x xccdf_file.xml -o myprofile -f ruby -s false  # To map stig.csv to inspec via map.yml
```

## inspec2xccdf

inspec2xccdf convertes an Inspec profile in json format to a STIG XCCDF Document
``` bash
USAGE: inspec_tools inspec2xccdf -j example.json -a attributes.yml -t application_name

FLAGS:
	-j --inspec_json : Path to inspec Json file created using command 'inspec json <profile> > example.json'
	-a --attributes  : Path to yml file that provides the required attributes for the XCCDF Document. Sample file can be generated using command 'inspec2xccdf generate_attribute_file'
	-o --output      : name or path to create the xccdf and title to give the xccdf
	-V --verbose     : verbose run [optional]

example: inspec_tools inspec2xccdf -j example.json -a attributes.yml -o application_name 
```

## inspec2ckl

inspec2ckl translates an Inspec results json into Stig Checklist

``` bash
USAGE: inspec_tools inspec2ckl -c checklist.ckl -j results.json -o output.ckl

FLAGS:
	-j --inspec_json : Path to Inspec results json file
	-o --output : Path to output checklist file
	-V --verbose : verbose run [optional]

example: inspec_tools inspec2ckl -j example.json -o application_name 
```

## pdf2inspec

pdf2inspec translates a pdf containing a CIS benchmark into an inspec profile

``` bash
USAGE: inspec_tools inspec2ckl -c checklist.ckl -j results.json -o output.ckl

FLAGS:
	-p --pdf                           : Path to CIS Benchmark pdf file
	-o --output                        : Path where to write the inspec profile to
  -f --format [ruby | hash]          : The format you would like (default: ruby) [optional]
  -s --seperate-files [true | false] : Output the resulting controls as one or mutiple files (default: true) [optional]
	-d --debug                         : debug run [optional]

example: inspec_tools pdf2inspec -p benchmark.pdf -o /path/to/myprofile -f ruby -s true
```


# Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

# License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
