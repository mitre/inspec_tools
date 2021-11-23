require 'json'
require_relative '../test_helper'
require 'stringio'
require 'fakefs/safe'
require 'o_stream_catcher'

class MetadataTest < Minitest::Test
  def setup
    OStreamCatcher.catch do
      @inspec_tools_instance = InspecTools::CLI.new([], {}, {})
    end
  end

  def test_metadata_inspec
    metadata = {}
    inspec_expected = { 'maintainer'=>'y', 'copyright'=>'y', 'copyright_email'=>'y', 'license'=>'y', 'version'=>'y' }

    FakeFS do
      test_populate_stdin(5) do
        OStreamCatcher.catch do
          @inspec_tools_instance.generate_inspec_metadata
        end
      end

      metadata = JSON.parse(File.read('metadata.json'))
    end
    assert_equal metadata, inspec_expected
  end

  def test_metadata_ckl
    metadata = {}
    ckl_expected = { 'benchmark'=>{ 'title'=>'y', 'version'=>'y', 'plaintext'=>'y' }, 'stigid'=>'y', 'role'=>'y', 'type'=>'y', 'hostname'=>'y', 'ip'=>'y', 'mac'=>'y', 'fqdn'=>'y', 'tech_area'=>'y', 'target_key'=>'y', 'web_or_database'=>'y', 'web_db_site'=>'y', 'web_db_instance'=>'y' }

    FakeFS do
      test_populate_stdin(15) do
        OStreamCatcher.catch do
          @inspec_tools_instance.generate_ckl_metadata
        end
      end

      metadata = JSON.parse(File.read('metadata.json'))
    end
    assert_equal metadata, ckl_expected
  end
end
