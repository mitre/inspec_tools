# This command is to be used by yes|inspec_tools generate_ckl_metadata in the build.yml for github.

metadata = $stdin.gets.chomp
ckl_expected = '{"benchmark":{"title":"y","version":"y","plaintext":"y"},"stigid":"y","role":"y","type":"y","hostname":"y","ip":"y","mac":"y","fqdn":"y","tech_area":"y","target_key":"y","web_or_database":"y","web_db_site":"y","web_db_instance":"y"}'
inspec_expected = '{"maintainer":"y","copyright":"y","copyright_email":"y","license":"y","version":"y"}'
if metadata == ckl_expected || metadata == inspec_expected # Test file for inspec or ckl metadata.json
  # print("good ckl or inspec metadata.json")
  exit(0)
elsif metadata == '<?xml version="1.0" encoding="UTF-8"?>' # Test if file is the inspec2ckl_metadata_test.ckl
  expected = ['<CHECKLIST>', '  <ASSET>', '    <ROLE>y</ROLE>', '    <ASSET_TYPE>y</ASSET_TYPE>', '    <HOST_NAME>y</HOST_NAME>', '    <HOST_IP>y</HOST_IP>', '    <HOST_MAC>y</HOST_MAC>', '    <HOST_FQDN>y</HOST_FQDN>', '    <TECH_AREA>y</TECH_AREA>', '    <TARGET_KEY>y</TARGET_KEY>', '    <WEB_OR_DATABASE>y</WEB_OR_DATABASE>', '    <WEB_DB_SITE>y</WEB_DB_SITE>', '    <WEB_DB_INSTANCE>y</WEB_DB_INSTANCE>', '  </ASSET>', '  <STIGS>', '    <iSTIG>', '      <STIG_INFO>', '        <SI_DATA>', '          <SID_NAME>stigid</SID_NAME>', '          <SID_DATA>y</SID_DATA>', '        </SI_DATA>', '        <SI_DATA>', '          <SID_NAME>version</SID_NAME>', '          <SID_DATA>y</SID_DATA>', '        </SI_DATA>', '        <SI_DATA>', '          <SID_NAME>releaseinfo</SID_NAME>', '          <SID_DATA>y</SID_DATA>', '        </SI_DATA>', '        <SI_DATA>', '          <SID_NAME>title</SID_NAME>', '          <SID_DATA>y</SID_DATA>', '        </SI_DATA>', '      </STIG_INFO>']
  expected.each do |line|
    input = $stdin.gets.chomp # Read each line from inspec2ckl_metadata_test.ckl
    # print('"'+input+'"'+"\n")
    if input != line # Test if line is not expected
      # print("bad inspec2ckl_metadata_test.ckl")
      exit(-1)
    end
  end
  # print("good inspec2ckl_metadata_test.ckl")
  exit(0)
end
# print("bad ckl or inspec metadata.json")
exit(-1) # If not the expected metadata.json or .ckl files, exit with error code
