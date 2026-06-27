# frozen_string_literal: true

require "typed_rails_enum_keys/version"
require "pathname"
require "typed_rails_enum_keys/configuration"
require "typed_rails_enum_keys/error"
require "typed_rails_enum_keys/enum_definition"
require "typed_rails_enum_keys/typescript/name_builder"
require "typed_rails_enum_keys/model_scanner"
require "typed_rails_enum_keys/typescript/model_file"
require "typed_rails_enum_keys/typescript/index_file"
require "typed_rails_enum_keys/registry"
require "typed_rails_enum_keys/typescript/writer"
require "typed_rails_enum_keys/watcher"

module TypedRailsEnumKeys
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

require "typed_rails_enum_keys/railtie" if defined?(Rails::Railtie)
