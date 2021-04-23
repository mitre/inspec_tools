require 'minitest/spec'
require 'minitest/autorun'

describe "HappyMapperTools::Benchmark::Ident correctly determines the system for each identifier" do
  # test values (tv); tv[0] == identifier, tv[1] == system
  tvList = {
    'CCI-000213' => 'http://cyber.mil/cci',
    'V-72859' =>    'http://cyber.mil/legacy',
    'SV-87511' =>   'http://cyber.mil/legacy',
    'CCI-00213' =>  'https://public.cyber.mil/stigs/cci/',
    'CCI-0000213' =>  'https://public.cyber.mil/stigs/cci/',
  }

  tvList.each do |identifier, system|
    it identifier do
      # Ident.new automatically determines ident.system
      ident = HappyMapperTools::Benchmark::Ident.new identifier
      assert_equal(system, ident.system)
    end
  end
end
