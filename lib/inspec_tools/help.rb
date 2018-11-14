module InspecTools::Help
  class << self
    def text(namespaced_command)
      path = namespaced_command.to_s.tr(':', '/')
      path = File.expand_path("../help/#{path}.md", __FILE__)
      IO.read(path) if File.exist?(path)
    end
  end
end
