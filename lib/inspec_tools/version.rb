require 'git-version-bump'

module InspecTools
  # Enable lite-tags (2nd parameter to git-version-bump version command)
  # Lite tags are tags that are used by GitHub releases that do not contain
  # annotations
  VERSION = GVB.version(false, true)
end
