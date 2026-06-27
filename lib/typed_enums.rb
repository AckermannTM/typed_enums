# frozen_string_literal: true

require "typed_enums/version"
require "pathname"
require "typed_enums/configuration"
require "typed_enums/error"
require "typed_enums/enum_definition"
require "typed_enums/naming/name_builder"
require "typed_enums/model_scanner"
require "typed_enums/output/javascript_file"
require "typed_enums/output/type_declaration_file"
require "typed_enums/registry"
require "typed_enums/output/writer"
require "typed_enums/watcher"

module TypedEnums
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
      Output::Writer.new(
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

require "typed_enums/railtie" if defined?(Rails::Railtie)
