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
gem 'inspec_tools', :git => "https://github.com/mitre/inspec-tools"
```

And then execute:

    $ bundle

Clone the repo and install it yourself as:

    $ gem install inspec_tools

# Usage

All of the binaries will print their `help` statements when executed without any arguments. From there it should be 

## xccdf2inspec

xccdf2inspec translates an xccdf file to an InSpec profile in one or many files
``` bash
USAGE: inspec_tools xccdf2inspec [OPTIONS] -x <xccdf-file>

FLAGS:
	-x --xccdf <xccdf-file>            : path to the disa stig xccdf file
	-a --attributes <xccdf-attr-yml>   : path to yml file to save XCCDF values which do not fit into the InSpec schema. These are useful if you want to convert the resulting profile back into XCCDF [optional]
	-o --output <profile-path>         : path to the InSpec profile output (default: profile) [optional]
	-f --format [ruby | hash]          : the format you would like (default: ruby) [optional]
	-s --separate-files [true | false] : output the resulting controls as one or mutiple files (default: true) [optional]
	-r --replace-tags <array>          : A case-sensitive, comma separated list to replace tags with a $ if found in a group rules description tag [optional]

example: inspec_tools xccdf2inspec -x xccdf_file.xml -a attributes.yml -o myprofile -f ruby -s false
```

## inspec2xccdf

inspec2xccdf converts an InSpec profile in json format to a STIG XCCDF Document
``` bash
USAGE: inspec_tools inspec2xccdf [OPTIONS] -j <inspec-json> -a <xccdf-attr-yml> -o <xccdf-xml>

FLAGS:
	-j --inspec-json <inspec-json>   : path to InSpec Json file created using command 'inspec json <profile> > example.json'
	-a --attributes <xccdf-attr-yml> : path to yml file that provides the required attributes for the XCCDF Document. these attributes are parts of XCCDF document which do not fit into the InSpec schema
	-o --output <xccdf-xml>          : name or path to create the xccdf and title to give the xccdf
	-V --verbose                     : verbose run [optional]

example: inspec_tools inspec2xccdf -j example.json -a attributes.yml -o xccdf.xml 
```

## csv2inspec

Convert a csv export of STIG controls to an InSpec profile
``` bash
USAGE: inspec_tools csv2inspec [OPTIONS] -c <stig-csv> -m <map-yml>

FLAGS:
	-c --csv <stig-csv>                : path to DISA Stig style csv
	-m --mapping <map-yml>             : path to yaml with mapping from CSV to InSpec Controls
	-V --verbose                       : verbose run [optional]
	-o --output <profile-path>         : path to the InSpec profile output (default: profile) [optional]
	-f --format [ruby | hash]          : the format you would like (default: ruby) [optional]
	-s --separate-files [true | false] : separate the controls into different files (default: true) [optional]

example: inspec_tools csv2inspec -c stig.csv -m map.yml -o mydir -f ruby -s true   # To map stig.csv to InSpec via map.yml
```

## inspec2csv

Convert an InSpec json to a csv file
``` bash
USAGE: inspec_tools inspec2csv [OPTIONS] -j <inspec-json> -o <profile-csv>

FLAGS:
	-j --inspec-json <inspec-json> : path to InSpec json file
	-o --output <profile-csv>      : path to output csv
	-V --verbose                   : run in verbose mode [optional]

example: inspec_tools inspec2csv -j inspec_profile.json -o mycsv.csv
```

## inspec2ckl

inspec2ckl translates an InSpec results json into Stig Checklist

``` bash
USAGE: inspec_tools inspec2ckl [OPTIONS] -j <inspec-json> -o <results-ckl>

FLAGS:
	-j --inspec-json <inspec-json> : path to InSpec results json file
	-o --output <results-ckl>      : path to output checklist file
	-V --verbose                   : verbose run [optional]

example: inspec_tools inspec2ckl -j results.json -o output.ckl 
```

## pdf2inspec

pdf2inspec translates a pdf containing a CIS benchmark into an InSpec profile

``` bash
USAGE: inspec_tools pdf2inspec [OPTIONS] -p <cis-benchmark>

FLAGS:
	-p --pdf <cis-benchmark>           : path to CIS Benchmark pdf file
	-o --output <profile-path>         : path to the InSpec profile output (default: profile) [optional]
	-f --format [ruby | hash]          : the format you would like (default: ruby) [optional]
	-s --separate-files [true | false] : output the resulting controls as multiple files (default: true) [optional]
	-d --debug                         : debug run [optional]

example: inspec_tools pdf2inspec -p benchmark.pdf -o /path/to/myprofile -f ruby -s true
```


# Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb` according to the [Semantic Versioning Policy](https://semver.org/). Then, run `bundle exec rake release` which will create a git tag for the specified version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

# License

The gem is available as open source under the terms of the [Apache 2.0 License](https://opensource.org/licenses/Apache-2.0)

# Notice

Copyright 2018 The MITRE Corporation

Approved for Public Release; Distribution Unlimited. Case Number 18-3678.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use 
this file except in compliance with the License. You may obtain a copy of the 
License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed 
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS 
OF ANY KIND, either express or implied. See the License for the specific language 
governing permissions and limitations under the License.
