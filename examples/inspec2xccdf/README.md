# Inspec2XCCDF Usage information

The InSpec to XCCDF Parser scans and extracts the results defined in the Inspec JSON results and converts them into a
XCCDF XML file to enable portability in publishing the execution results in consuming tools.

The parser requires two files:

1. The Inspec JSON results file
1. The XCCDF attributes file. See `xccdf2inspec` option `--attributes` for how to generate a base attribute file from the source specification.

If all of the following requirements are followed, a XML will be produced conforming to the [XCCDF 1.1 specification](https://csrc.nist.gov/publications/detail/nistir/7275/rev-3/final).
Note: All files in the /test/schemas/xccdf_114 directory are directly sourced from <https://csrc.nist.gov/Projects/Security-Content-Automation-Protocol/Specifications/xccdf#resource-1.1.4>.

## XCCDF attributes YAML file

Inspec is unable to produce certain data that is required for conversion into conforming XCCDF. The attributes marked 'Required'
below `MUST` be included in a XCCDF attributes YAML file and provided as part of the Inspec2XCCDF conversion process.

```yaml
benchmark.id            # Required: Benchmark id
benchmark.status        # Required: Benchmark status. Must be one of 'accepted', 'deprecated', 'draft', 'incomplete', 'interim'
benchmark.version       # Required: Benchmark version
```

The following attributes `SHOULD` be included in order to more closely generate an XCCDF that matches the original.

```yaml
benchmark.status.date   # Optional: Benchmark status date
benchmark.title         # Optional: Benchmark title
reference.href          # Optional: Benchmark reference href
reference.dc.publisher  # Optional: Benchmark and Rule reference publisher
reference.dc.source     # Optional: Benchmark and Rule reference source
reference.dc.title      # Optional: Rule reference title
reference.dc.subject    # Optional: Rule reference subject
reference.dc.type       # Optional: Rule reference type
reference.dc.identifier # Optional: Rule reference identifier
```

## Metadata json file

### Inclusion of test results within the XCCDF output

Test results from an Inspec execution will be included in the output only if fqdn is provided at minimum for the fulfilment
of valid XCCDF.

Example execution: 

```
inspec_tools inspec2xccdf -j examples/sample_json/rhel-simp.json -a lib/data/attributes.yml -m examples/inspec2xccdf/metadata.json -o output.xccdf
```

JSON format:

```text
	"hostname" : "myawesome",
	"ip" : "10.10.10.10",           # Optional: A IPV4, IPV6, or MAC address. Applied to TestResult target-address and target-facts element.
	"fqdn" : "myawesome.host.com",  # Required: The host that is the target of the execution. Applied to TestResult target element.
	"mac" : "aa:aa:99:99:99:99",    # Optional: A MAC address to include. Applied to TestResult target-facts element.
	"identity" : {
		"identity" : "userabc",  # Optional: Account used to perform scan operation. Applied to TestResult identity element.
		"privileged" : true,     # Optional: Indicator of whether the identity has priviliged access. Applied to TestResult identity element.
	},
	"organization" : "MITRE Corporation"  # Optional: Name of organization applying this benchmark. Applied to TestResult organization element.
```

## Inspec JSON result file

Inspec will not prevent execution of controls with missing required tags defined since it is a general purpose framework.
However, doing so will result in non-conforming XCCDF 1.1 output. In order to generate conforming XCCDF, the tags marked
'Required' below MUST be included in each of the Inspec controls.

| Tag | Required | XCCDF Element |
| --- | --- | --- |
| gid | yes | Group attribute id |
| gdescription | no | Group description |
| gtitle | no | Group title |
| rid | yes | Rule attribute id |
| severity | yes | Rule attribute severity. Must be one of 'unknown', 'info', 'low', 'medium', 'high' |
| rweight | no | Rule weight. If missing, this may make the scoring results out of line as compared to an originating XCCDF Benchmark specification. |
| title | no | Rule title |
| cci | no | Rule ident |
| fix | no | Rule fixTextType content |
| fixref | no | Rule fixTextType fixref |
| checkref | no | TestResult rule-result check system attribute |

