gem build ../inspec_tools.gemspec  

cp ../inspec_tools-xxx.gem gems/

gem generate_index --directory ./

sign & commit & push
