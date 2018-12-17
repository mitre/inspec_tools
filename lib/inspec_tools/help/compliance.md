  compliance parses an inspec results json to check if the compliance level meets a specified threshold
  
Examples:

  inspec_tools compliance -j examples/sample_json/rhel-simp.json -i '{compliance.min: 80, failed.critical.max: 0, failed.high.max: 0}'

  inspec_tools compliance -j examples/sample_json/rhel-simp.json -f examples/sample_yaml/threshold.yaml