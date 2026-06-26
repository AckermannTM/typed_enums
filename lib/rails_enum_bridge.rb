# frozen_string_literal: true

require "rails_enum_bridge/version"
require "pathname"
require "rails_enum_bridge/configuration"
require "rails_enum_bridge/error"
require "rails_enum_bridge/enum_definition"
require "rails_enum_bridge/typescript/name_builder"
require "rails_enum_bridge/model_scanner"
require "rails_enum_bridge/typescript/model_file"
require "rails_enum_bridge/typescript/index_file"
require "rails_enum_bridge/registry"
require "rails_enum_bridge/typescript/writer"
require "rails_enum_bridge/watcher"

module RailsEnumBridge
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    def generate(logger: nil)
      write(check: false, logger:)
    end

    def check(logger: nil)
      write(check: true, logger:)
    end

    def watch(logger: nil)
      Watcher.start(logger: logger || default_logger)
    end

    def stop_watcher
      Watcher.stop
    end

    private

    def write(check:, logger:)
      TypeScript::Writer.new(
        output_dir: output_path,
        expected_files: Registry.new.expected_files,
        logger: logger || default_logger,
        check:
      ).call
    end

    def output_path
      configured_path = Pathname(configuration.output_dir)
      configured_path.absolute? ? configured_path : Rails.root.join(configured_path)
    end

    def default_logger
      defined?(Rails) ? Rails.logger : nil
    end
  end
end

require "rails_enum_bridge/railtie" if defined?(Rails::Railtie)
