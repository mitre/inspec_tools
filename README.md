# InspecTo

InspecTo supplies several CLI tools to convert to and from InSpec format. The Converters in version 0.2 are:

* csv2inspec
* xccdf2inspec
* inspec2ckl
* inspec2xccdf

The Ruby API is defined in lib/inspec_to.rb

# Installation

Ensure happymapper is not installed, as it will take precedence over nokogiri-happymapper.

Add this line to your application's Gemfile:

```ruby
gem 'inspec_to', :git => "https://gitlab.mitre.org/inspec/inspec_to.git"
```

And then execute:

    $ bundle

Clone the repo and install it yourself as:

    $ gem install inspec_to

# Usage

All of the binaries will print their `help` statements when executed without any arguments. From there it should be 

## CSV2Inspec 

Convert a csv export of STIG controls to an inspec profile with `csv2inspec`
``` bash	
USAGE: csv2inspec -c a_stig.csv -m map.yml 

FLAGS:
	-c --csv : Path to DISA Stig style csv
	-m --mapping : Path to yaml with mapping from CSV to Inspec Controls
	-V --verbose : verbose run [optional]

example: csv2inspec exec -c stig.csv -m map.yml   # To map stig.csv to inspec via map.yml


example: csv2inspec generate_map    # to generate mapping template
```

## XCCDF2Inspec
XCCDF2Inspec translates an xccdf file to an inspec profile in one or many files
``` bash
USAGE: xccdf2inxpec exec -c cci_list.xml -x xccdf_file.xml -o myprofile -f ruby

FLAGS:
	-x --xccdf : Path to the disa stig xccdf file
	-c --cci : Path to the cci xml file
	-o --output : The name of the inspec file to generate [optional]
	-f --format [ruby | hash] : The format you would like (default: ruby) [optional]
	-s --seperate-files [true | false] : Output the resulting controls as one or mutiple files (default: true) [optional]
	-r --replace-tags array (case sensitive): A comma seperated list to replace tags with a $ if found in a group rules description tag [optional]
```

## inspec2xccdf

Inspec2xccdf convertes an Inspec profilein json format to a STIG XCCDF Document

``` bash
USAGE: inspec2xccdf exec -j example.json -a attributes.yml -t application_name

FLAGS:
	-j --inspec_json : Path to inspec Json file created using command 'inspec json <profile> > example.json
	-a --attributes  : Path to yml file that provides the required attributes for the XCCDF Document. Sample file can be generated using command 'inspec2xccdf generate_attribute_file'
	-t --xccdf_title : xccdf title
	-V --verbose     : verbose run [optional]


example: inspec2xccdf generate_attribute_file # to generate mapping template named attributes.yml
```

## Inspec2CKL
Inspec2ckl translates an Inspec results json into Stig Checklist

``` bash
USAGE: inspec2ckl exec -c checklist.ckl -j results.json -o output.ckl

FLAGS:
	-j --json : Path to Inspec results json file
	-c --cklist : Path to Stig Checklist file
	-t --title : Title of Stig Checklist file [optional]
	-d --date : Date of the Stig Checklist file [optional]
	-a --attrib : Path to attributes yaml file
	-o --output : Path to output checklist file
	-V --verbose : verbose run [optional]
```


# Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

# License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
