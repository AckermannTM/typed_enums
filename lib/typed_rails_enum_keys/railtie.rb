# frozen_string_literal: true

require "rails/railtie"

module TypedRailsEnumKeys
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("tasks.rb", __dir__)
    end

    config.after_initialize do
      TypedRailsEnumKeys::Railtie.install_development_hooks
    end

    def self.install_development_hooks
      return unless Rails.env.development?

      if TypedRailsEnumKeys.configuration.auto_generate_in_development
        Rails.application.reloader.to_prepare do
          TypedRailsEnumKeys.generate
        end
      end

      return unless TypedRailsEnumKeys.configuration.watch_models_in_development

      TypedRailsEnumKeys.watch
    end
  end
end
