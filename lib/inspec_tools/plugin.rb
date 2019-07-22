# frozen_string_literal: true

module InspecToolsPlugin
  class Plugin < Inspec.plugin(2)
    # Metadata
    # Must match entry in plugins.json
    plugin_name :'inspec-tools_plugin'

    # Activation hooks (CliCommand as an example)
    cli_command :tools do
      require_relative 'plugin_cli'
      InspecPlugins::InspecToolsPlugin::CliCommand
    end
  end
end
