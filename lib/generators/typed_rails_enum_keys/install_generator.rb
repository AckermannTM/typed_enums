# frozen_string_literal: true

require "rails/generators"

module TypedRailsEnumKeys
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def create_initializer
      template "initializer.rb", "config/initializers/typed_rails_enum_keys.rb"
    end

    def create_generated_directory
      create_file "app/frontend/generated/rails/.keep", ""
    end
  end
end
