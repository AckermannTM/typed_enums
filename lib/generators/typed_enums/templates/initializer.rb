# frozen_string_literal: true

TypedEnums.configure do |config|
  # Generated JavaScript and TypeScript declaration files are written here.
  config.output_dir = "app/javascript/lib"

  # Automatically regenerate enum files in development.
  config.auto_generate_in_development = true

  # Watch app/models in development and regenerate after saves.
  config.watch_models_in_development = true
end
