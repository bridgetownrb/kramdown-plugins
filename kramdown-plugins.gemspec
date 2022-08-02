# frozen_string_literal: true

require_relative "lib/kramdown/plugins/version"

Gem::Specification.new do |spec|
  spec.name = "kramdown-plugins"
  spec.version = Kramdown::Plugins::VERSION
  spec.author = "Bridgetown Team"
  spec.email = "maintainers@bridgetownrb.com"

  spec.summary = "Provides a Kramdown parser with an extensible plugin system"
  spec.homepage = "https://github.com/bridgetownrb/kramdown-plugins"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "kramdown", ">= 2.4"
end
