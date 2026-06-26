# frozen_string_literal: true

module RailsEnumBridge
  class Configuration
    attr_accessor :output_dir, :root_model_class, :auto_generate_in_development, :watch_models_in_development

    def initialize
      @output_dir = "app/frontend/generated/rails"
      @root_model_class = "ApplicationRecord"
      @auto_generate_in_development = true
      @watch_models_in_development = true
    end
  end
end
