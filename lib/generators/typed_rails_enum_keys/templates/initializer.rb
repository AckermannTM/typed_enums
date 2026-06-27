# frozen_string_literal: true

TypedRailsEnumKeys.configure do |config|
  # Generated TypeScript files are written here.
  config.output_dir = "app/frontend/generated/rails"

  # Automatically regenerate enum files in development.
  config.auto_generate_in_development = true

  # Watch app/models in development and regenerate after saves.
  config.watch_models_in_development = true
end
