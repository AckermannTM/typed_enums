# frozen_string_literal: true

require_relative "lib/typed_rails_enum_keys/version"

Gem::Specification.new do |spec|
  spec.name = "typed_rails_enum_keys"
  spec.version = TypedRailsEnumKeys::VERSION
  spec.authors = ["typed_rails_enum_keys contributors"]
  spec.email = ["maintainers@example.com"]

  spec.summary = "Export Rails Active Record enums to TypeScript constants and union types."
  spec.description = "typed_rails_enum_keys generates framework-agnostic TypeScript modules from Rails model enums."
  spec.homepage = "https://github.com/example/typed_rails_enum_keys"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir.chdir(__dir__) do
    Dir[
      "CHANGELOG.md",
      "LICENSE.txt",
      "README.md",
      "lib/**/*.rb"
    ]
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "listen", ">= 3.5", "< 4.0"
  spec.add_dependency "rails", ">= 7.1", "< 9.0"

  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "rspec", ">= 3.13"
  spec.add_development_dependency "rubocop", ">= 1.60"
  spec.add_development_dependency "rubocop-rails", ">= 2.25"
end
