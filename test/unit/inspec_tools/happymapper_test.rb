require 'minitest/spec'
require 'minitest/autorun'

describe "HappyMapperTools::Benchmark::Ident correctly determines the system for each identifier" do
  # test values (tv); tv[0] == identifier, tv[1] == system
  tvList = [
    ['CCI-000213',  'http://cyber.mil/cci'],
    ['V-72859',     'http://cyber.mil/legacy'],
    ['SV-87511',    'http://cyber.mil/legacy'],
    ['CCI-00213',   'https://public.cyber.mil/stigs/cci/'],
    ['CCI-0000213',   'https://public.cyber.mil/stigs/cci/'],
  ]

  tvList.each do |tv|
    it tv[0] do
      # Ident.new automatically determines ident.system
      ident = HappyMapperTools::Benchmark::Ident.new tv[0]
      assert_equal(tv[1], ident.system)
    end
  end
end
