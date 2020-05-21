# InspecTools

![Overall Status](https://github.com/mitre/inspec_tools/workflows/inspec_tools/badge.svg)
![Inspec Tools Release](https://github.com/mitre/inspec_tools/workflows/Release%20Management/badge.svg)

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
- xlsx2inspec

It also includes an API that can be used in a ruby application. The Ruby API is defined in lib/inspec_tools/inspec.rb

# Installation

Ensure `happymapper` is not installed, as it will take precedence over `nokogiri-happymapper`.

Add this line to your application's Gemfile:

```
gem 'inspec_tools'
```

Docker installation have the Dockerfile and run `docker build -t <image name>`

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

### generate_map

This command will generate a `mapping.xml` file that can be passed in to the `csv2inspec` command with the `--m` option.

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

## Docker Usage

Building the Docker container and running it with `docker run -v` `` ` ``pwd`` ` `` `:/share -e CHEF_LICENSE=accept <image name>` will print a listing of all the command with a short description.
For detailed help on any command, run `docker run -v` `` ` ``pwd`` ` `` `:/share -e CHEF_LICENSE=accept <image name> help [COMMAND]`. Help can also be called with the `-h, --help` flags after any command, like `docker run -v` `` ` ``pwd`` ` `` `:/share -e CHEF_LICENSE=accept <image name> xccdf2inspec -h`.
`` test` ``

### generate_map

This command will generate a `mapping.xml` file that can be passed in to the `csv2inspec` command with the `--m` option.

```
USAGE: docker run -v`pwd`:/share -e CHEF_LICENSE=accept <image name> generate_map
```

## generate_ckl_metadata

This command will generate a `metadata.json` file that can be passed in to the `inspec2ckl` command with the `-m` option.

```
USAGE: docker run -it -v `pwd`:/share -e CHEF_LICENSE=accept <image name> generate_ckl_metadata
```

## generate_inspec_metadata

This command will generate a `metadata.json` file that can be passed in to the `xccdf2inspec` command with the `-m` option.

```
USAGE: docker run -it -v `pwd`:/share -e CHEF_LICENSE=accept <image name> generate_inspec_metadata
```

## compliance

`compliance` parses an inspec results json to check if the compliance level meets a specified threshold.

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

#### In-Line Examples
```
{compliance: {min: 90}, failed: {critical: {max: 0}, high: {max: 0}}}
```

```
{compliance.min: 81, failed.critical.max: 0, failed.high.max: 0}
```

## summary

`summary` parses an inspec results json to create a summary json

```
USAGE: inspec_tools summary [OPTIONS] -j <inspec-json> -o <summary-csv>

FLAGS:
	-j --inspec-json <inspec-json>   : path to InSpec results JSON
	-o --output <output-json> 		   : path to summary JSON
  -c --cli, --no-cli               : print formatted summary to STDOUT
  -V --verbose, --no-verbose       : print verbose an debug output
  -f --json-full, --no-json-full   : print the summary STDOUT as JSON
  -k --json-counts, --no-json_cou  : print the reslut status to STDOUT as JSON

Examples:

  inspec_tools summary -j examples/sample_json/rhel-simp.json -f -o summary.json -c
```

## xccdf2inspec

`xccdf2inspec` converts a STIG XCCDF file to an InSpec profile

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

`inspec2xccdf` converts an InSpec profile in json format to a STIG XCCDF Document

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

`csv2inspec` converts a csv security control spreadsheet of STIG controls to an InSpec profile

```
USAGE: inspec_tools csv2inspec [OPTIONS] -c <stig-csv> -m <map-yml>

FLAGS:
	-c --csv <stig-csv>                : path to DISA Stig style csv
	-m --mapping <map-yml>             : path to yaml with mapping from CSV to InSpec Controls
	-V --verbose                       : verbose run [optional]
	-o --output <profile-path>         : path to the InSpec profile output (default: profile) [optional]
	-f --format [ruby | hash]          : the format you would like (default: ruby) [optional]
	-s --separate-files [true | false] : separate the controls into different files (default: true) [optional]

example: inspec_tools csv2inspec -c examples/csv2inspec/stig.csv -m examples/csv2inspec/mapping.yml -o mydir -f ruby -s true   # To map stig.csv to InSpec via mapping.yml
```

## inspec2csv

`inspec2csv` converts an InSpec profile in json format to a csv security control spreadsheet

```
USAGE: inspec_tools inspec2csv [OPTIONS] -j <inspec-json> -o <profile-csv>

FLAGS:
	-j --inspec-json <inspec-json> : path to InSpec json file
	-o --output <profile-csv>      : path to output csv
	-V --verbose                   : run in verbose mode [optional]

example: inspec_tools inspec2csv -j inspec_profile.json -o mycsv.csv
```

## inspec2ckl

`inspec2ckl` translates an InSpec results json into Stig Checklist

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

`pdf2inspec` translates a pdf containing a CIS benchmark into an InSpec profile.

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

## xlsx2inspec
```
Usage:
  inspec_tools xlsx2inspec -m, --mapping=MAPPING -p, --control-name-prefix=CONTROL_NAME_PREFIX -x, --xlsx=XLSX

Options:
  -x, --xlsx=XLSX
  -m, --mapping=MAPPING
  -p, --control-name-prefix=CONTROL_NAME_PREFIX
  -V, [--verbose], [--no-verbose]
  -o, [--output=OUTPUT]
                                                 # Default: profile
  -f, [--format=FORMAT]
                                                 # Default: ruby
                                                 # Possible values: ruby, hash
  -s, [--separate-files], [--no-separate-files]
                                                 # Default: true
      [--log-level=LOG_LEVEL]                    # Set the logging level: ["debug", "info", "warn", "error", "fatal"]
      [--log-location=LOG_LOCATION]              # Location to send diagnostic log messages to. (default: $stdout or Inspec::Log.error)
  l, [--log-directory=LOG_DIRECTORY]             # Provie log location

xlsx2inspec translates CIS Benchmarks in XLSX format to Inspec controls using a mapping file

See examples/xlsx2inspec/mapping.cis.yml for an example mapping file

example: bundle exec inspec_tools xlsx2inspec -m examples/xlsx2inspec/mapping.cis.yml -p azure-cis-foundations -x examples/cis.xlsx
```

## version

Prints out the gem version

```
USAGE: inspec_tools version
```

# Format of Input and Output Files

InspecTools will make a best effort approach when converting various legacy terms and values in input files. If some terminology is not supported, please open an issue.

InspecTools is opinionated about the output of its profiles. Profiles generated by InspecTools generally attempt to adhere to latest National Institute of Standards and Technology (NIST) terms and values, such as the Common Vulnerability Scoring System (CVSS).

View our wiki pages on [expected](https://github.com/mitre/inspec_tools/wiki/Expected-Input) input and [expected output](https://github.com/mitre/inspec_tools/wiki/Expected-Output) for more information about what is currently supported input and expected output.

# `inspec_tools` Development

View our [wiki page](https://github.com/mitre/inspec_tools/wiki/Development) for more information on contributing.

# Publishing a Release

If you are a maintainer, it is very easy to cut a release of this gem:

1. Click on "Releases" and there should be a draft pending.
2. Make sure the Tag version and Release title match!
3. Add any additional notes can be added in the Description box.
4. Click "Publish release".
5. Release notes will be posted and a new gem will be pushed to Rubygems & Github Packages with the version you specified on step 2.

### NOTICE

© 2018 The MITRE Corporation.

Approved for Public Release; Distribution Unlimited. Case Number 18-3678.

### NOTICE

MITRE hereby grants express written permission to use, reproduce, distribute, modify, and otherwise leverage this software to the extent permitted by the licensed terms provided in the LICENSE.md file included with this project.

### NOTICE

This software was produced for the U. S. Government under Contract Number HHSM-500-2012-00008I, and is subject to Federal Acquisition Regulation Clause 52.227-14, Rights in Data-General.

No other use other than that granted to the U. S. Government, or to those acting on behalf of the U. S. Government under that Clause is authorized without the express written permission of The MITRE Corporation. DISA STIGs are published by DISA, see: https://public.cyber.mil/privacy-security/
