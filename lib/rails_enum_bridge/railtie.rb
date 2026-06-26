# frozen_string_literal: true

require "rails/railtie"

module RailsEnumBridge
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("tasks.rb", __dir__)
    end

    config.after_initialize do
      RailsEnumBridge::Railtie.install_development_hooks
    end

    def self.install_development_hooks
      return unless Rails.env.development?

      if RailsEnumBridge.configuration.auto_generate_in_development
        Rails.application.reloader.to_prepare do
          RailsEnumBridge.generate
        end
      end

      return unless RailsEnumBridge.configuration.watch_models_in_development

      RailsEnumBridge.watch
    end
  end
end
