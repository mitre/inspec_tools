# InspecTools

InspecTools supplies several CLI tools to convert to and from InSpec format.

The inspec_tools support the following modules:

- generate_map
- generate_ckl_metadata
- generate_inspec_metadata
- compliance
- summary
- csv2inspec
- inspec2csv
- xccdf2inspec
- inspec2xccdf
- inspec2ckl
- pdf2inspec

It also includes an API that can be used in a ruby application. The Ruby API is defined in lib/inspec_tools/inspec.rb

# Installation

Ensure `happymapper` is not installed, as it will take precedence over `nokogiri-happymapper`.

Add this line to your application's Gemfile:

```
gem 'inspec_tools'
```

# Usage

## Ruby Usage

The gem exposes methods for converting from an InSpec results JSON to three formats: CKL, XCCDF, and CSV. In the ruby file add a require statement:

```
require 'inspec_tools'
```

Pass in the results JSON object to the InspecTools class to get an object that can convert the results into the three formats:

```
tool = InspecTools::Inspec.new(results_json)
ckl_reuslts = tool.to_ckl
csv_results = tool.to_ccsv
```

The XCCDF converter requires a parameter - a JSON object containing attributes that exist in the XCCDF format, but don't exist in the InSpec results JSON. There's an example of these attributes at [examples/attribute.json](examples/attribute.json).

```
xccdf_results = tool.to_xccdf(attribs_json)
```

## Command line Usage

On the Command Line, `inspec_tools help` will print a listing of all the command with a short description.
For detailed help on any command, run `inspec_tools help [COMMAND]`. Help can also be called with the `-h, --help` flags after any command, like `inspec_tools xccdf2inspec -h`.

## generate_map

This command will generate a `mapping.xml` file that can be passed in to the `csv2inspec` command with the `-m` option.

```
USAGE: inspec_tools generate_map
```

## generate_ckl_metadata

This command will generate a `metadata.json` file that can be passed in to the `inspec2ckl` command with the `-m` option.

```
USAGE: inspec_tools generate_ckl_metadata
```

## generate_inspec_metadata

This command will generate a `metadata.json` file that can be passed in to the `xccdf2inspec` command with the `-m` option.

```
USAGE: inspec_tools generate_inspec_metadata
```

## compliance

compliance parses an inspec results json to check if the compliance level meets a specified threshold.

If the specified threshold is not met, an error code (1) is returned along with non-compliant elements.

```
USAGE:  inspec_tools compliance [OPTIONS] -j <inspec-json> -i <threshold-inline>
	inspec_tools compliance [OPTIONS] -j <inspec-json> -f <threshold-file>
FLAGS:
	-j --inspec-json <inspec-json>          : path to InSpec results Json
	-i --template-inline <threshold-inline> : inline compliance threshold definition
	-f --template-file <threshold-file>     : yaml file with compliance threshold definition
Examples:

  inspec_tools compliance -j examples/sample_json/rhel-simp.json -i '{compliance.min: 80, failed.critical.max: 0, failed.high.max: 0}'

  inspec_tools compliance -j examples/sample_json/rhel-simp.json -f examples/sample_yaml/threshold.yaml
```

### YAML file or In-line threshold definition styles:

#### File Examples
```
failed:
  critical:
    max: 0
  high:
    max: 1
compliance:
  min: 81
```

```
compliance.min: 81
failed.critical.max: 1
failed.high.max: 1
```

#### In-Line Exmamples
```
{compliance: {min: 90}, failed: {critical: {max: 0}, high: {max: 0}}}
```

```
{compliance.min: 81, failed.critical.max: 0, failed.high.max: 0}
```

## summary

summary parses an inspec results json to create a summary json

```
USAGE: inspec_tools summary [OPTIONS] -j <inspec-json> -o <summary-csv>

FLAGS:
	-j --inspec-json <inspec-json>  : path to InSpec results Json
	-o --output <output-json> 		: path to summary json
    -c --cli <output-cli>           : print summary to stdout

Examples:

  inspec_tools summary -j examples/sample_json/rhel-simp.json -o summary.json -c
```

## xccdf2inspec

xccdf2inspec translates an xccdf file to an InSpec profile in one or many files

```
USAGE: inspec_tools xccdf2inspec [OPTIONS] -x <xccdf-file>

FLAGS:
	-x --xccdf <xccdf-file>            : path to the disa stig xccdf file
	-a --attributes <xccdf-attr-yml>   : path to yml file to save XCCDF values which do not fit into the InSpec schema. These are useful if you want to convert the resulting profile back into XCCDF [optional]
	-o --output <profile-path>         : path to the InSpec profile output (default: profile) [optional]
	-f --format [ruby | hash]          : the format you would like (default: ruby) [optional]
	-s --separate-files [true | false] : output the resulting controls as one or mutiple files (default: true) [optional]
	-m --metadata <metadata-json>      : path to json file with additional metadata for the inspec.yml file [optional]
	-r --replace-tags <array>          : A case-sensitive, comma separated list to replace tags with a $ if found in a group rules description tag [optional]

example: inspec_tools xccdf2inspec -x xccdf_file.xml -a attributes.yml -o myprofile -f ruby -s false
```

## inspec2xccdf

inspec2xccdf converts an InSpec profile in json format to a STIG XCCDF Document

```
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

```
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

```
USAGE: inspec_tools inspec2csv [OPTIONS] -j <inspec-json> -o <profile-csv>

FLAGS:
	-j --inspec-json <inspec-json> : path to InSpec json file
	-o --output <profile-csv>      : path to output csv
	-V --verbose                   : run in verbose mode [optional]

example: inspec_tools inspec2csv -j inspec_profile.json -o mycsv.csv
```

## inspec2ckl

inspec2ckl translates an InSpec results json into Stig Checklist

```
USAGE: inspec_tools inspec2ckl [OPTIONS] -j <inspec-json> -o <results-ckl>

FLAGS:
	-j --inspec-json <inspec-json> : path to InSpec results json file
	-o --output <results-ckl>      : path to output checklist file
	-m --metadata <metadata-json>  : path to json file with additional metadata for the checklist file [optional]
	-V --verbose                   : verbose run [optional]

example: inspec_tools inspec2ckl -j results.json -o output.ckl
```

## pdf2inspec

pdf2inspec translates a pdf containing a CIS benchmark into an InSpec profile.

```
USAGE: inspec_tools pdf2inspec [OPTIONS] -p <cis-benchmark>

FLAGS:
	-p --pdf <cis-benchmark>           : path to CIS Benchmark pdf file
	-o --output <profile-path>         : path to the InSpec profile output (default: profile) [optional]
	-f --format [ruby | hash]          : the format you would like (default: ruby) [optional]
	-s --separate-files [true | false] : output the resulting controls as multiple files (default: true) [optional]
	-d --debug                         : debug run [optional]

example: inspec_tools pdf2inspec -p benchmark.pdf -o /path/to/myprofile -f ruby -s true
```

## version

Prints out the gem version

```
USAGE: inspec_tools version
```

# Development / PR process

This gem was developed using the [CLI Template](https://github.com/tongueroo/cli-template), a generator tool that builds a starter CLI project.

## A complete PR should include 7 core elements:  

- A signed PR ( aka `git commit -a -s` )
- Code for the new functionality
- Updates to the CLI
- New unit tests for the functionality
- Updates to the docs and examples in `README.md` and `./docs/*`
- (if needed) Example / Template files ( `metadata.yml`,`example.yml`, etc )
  - Scripts / Scaffolding code for the Example / Template files ( `generate_map` is an example )
- Example Output of the new functionality if it produces an artifact

1. open an issue on the main inspec_tools website noting the issues your PR will address
2. fork the repo
3. checkout your repo
4. cd to the repo
5. git co -b `<your_branch>`
6. bundle install
7. `hack as you will`
8. test via rake
9. ensure unit tests still function and add unit tests for your new feature
10. add new docs to the `README.md` and to `./docs/examples`
11. update the CLI as needed and add in `usage` example
12. (if needed) create and document any example or templates
13. (if needed) create any supporing scripts
14. (opt) gem build inspec_tools.gemspec
15. (opt) gem install inspec_tools
16. (opt) test via the installed gem
17. git commit -a -s `<your_branch>`
18. Open a PRs aginst the MITRE inspec_tools repo

# Testing  

There are a set of unit tests. Run `rake test` to run the tests.

To release a new version, update the version number in `version.rb` according to the [Semantic Versioning Policy](https://semver.org/).

Then, run `bundle exec rake release` which will create a git tag for the specified version, push git commits and tags, and push the `.gem` file to [github.com](https://github.com/mitre/inspec_tools).

### NOTICE

© 2018 The MITRE Corporation.

Approved for Public Release; Distribution Unlimited. Case Number 18-3678.

### NOTICE

MITRE hereby grants express written permission to use, reproduce, distribute, modify, and otherwise leverage this software to the extent permitted by the licensed terms provided in the LICENSE.md file included with this project.

### NOTICE

This software was produced for the U. S. Government under Contract Number HHSM-500-2012-00008I, and is subject to Federal Acquisition Regulation Clause 52.227-14, Rights in Data-General.

No other use other than that granted to the U. S. Government, or to those acting on behalf of the U. S. Government under that Clause is authorized without the express written permission of The MITRE Corporation.DISA STIGs are published by DISA IASE, see: https://iase.disa.mil/Pages/privacy_policy.aspx
