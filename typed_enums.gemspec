# frozen_string_literal: true

require_relative "lib/typed_enums/version"

Gem::Specification.new do |spec|
  spec.name = "typed_enums"
  spec.version = TypedEnums::VERSION
  spec.authors = ["Ackermann"]
  spec.email = ["ghostkominfinity@gmail.com"]

  spec.summary = "Export Rails Active Record enums to JavaScript constants and TypeScript declaration types."
  spec.description = "typed_enums generates a framework-agnostic JavaScript enum module from Rails model enums."
  spec.homepage = "https://github.com/AckermannTM/typed_enums"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata = {
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

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rubocop", "~> 1.60"
  spec.add_development_dependency "rubocop-rails", "~> 2.25"
end
