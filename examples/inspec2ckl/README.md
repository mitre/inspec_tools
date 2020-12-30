# Inspec2CKL Usage information

The InSpec to Checklist Parser scans and extracts the results defined in the Inspec JSON results and converts them into a
Checklist XML file for use with STIGViewer.

## XCCDF attributes YAML file

### Inclusion of STIG information within the Checklist output.

Inspec is unable to produce certain data that is required for conversion into a fully populated checklist. The following
attributes supplement this data

```yaml
benchmark.title            # SI_DATA title, STIG_DATA STIGRef
benchmark.plaintext        # SI_DATA releaseinfo, STIG_DATA STIGRef
benchmark.version       # SI_DATA version, STIG_DATA STIGRef
```

## Metadata json file

### Inclusion of host information within the Checklist output.

Host information will only be included in the produced checklist when the host metadata is provided.

Example execution: 

```
inspec_tools inspec2ckl -j examples/sample_json/rhel-simp.json -a lib/data/attributes.yml -m examples/inspec2ckl/metadata.json -o output.ckl
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
