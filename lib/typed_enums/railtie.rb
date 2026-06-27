# frozen_string_literal: true

require "rails/railtie"

module TypedEnums
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path("tasks.rb", __dir__)
    end

    config.after_initialize do
      TypedEnums::Railtie.install_development_hooks
    end

    def self.install_development_hooks
      return unless Rails.env.development?

      if TypedEnums.configuration.auto_generate_in_development
        Rails.application.reloader.to_prepare do
          TypedEnums.generate
        end
      end

      return unless TypedEnums.configuration.watch_models_in_development

      TypedEnums.watch
    end
  end
end
