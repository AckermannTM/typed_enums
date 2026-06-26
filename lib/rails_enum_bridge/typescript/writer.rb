# frozen_string_literal: true

require "fileutils"
require "pathname"

module RailsEnumBridge
  module TypeScript
    class Writer
      GENERATED_MARKER = ModelFile::HEADER

      Result = Data.define(:changed, :missing, :extra, :unchanged) do
        def stale?
          changed.any? || missing.any? || extra.any?
        end

        def summary
          sections = []
          sections << "missing: #{missing.join(', ')}" if missing.any?
          sections << "changed: #{changed.join(', ')}" if changed.any?
          sections << "extra: #{extra.join(', ')}" if extra.any?
          sections.join("\n")
        end
      end

      def initialize(output_dir:, expected_files:, logger: default_logger, check: false)
        @output_dir = Pathname(output_dir)
        @expected_files = expected_files
        @logger = logger
        @check = check
      end

      def call
        ensure_output_dir unless check

        result = Result.new(changed: [], missing: [], extra: [], unchanged: [])
        reconcile_expected_files(result)
        reconcile_stale_files(result)
        result
      end

      private

      attr_reader :output_dir, :expected_files, :logger, :check

      def reconcile_expected_files(result)
        expected_files.sort.each do |relative_path, content|
          path = output_dir.join(relative_path)

          if !path.exist?
            result.missing << relative_path
            write_file(path, content) unless check
          elsif path.read == content
            result.unchanged << relative_path
          else
            result.changed << relative_path
            write_file(path, content) unless check
          end
        end
      end

      def reconcile_stale_files(result)
        generated_files.each do |path|
          relative_path = path.relative_path_from(output_dir).to_s
          next if expected_files.key?(relative_path)

          result.extra << relative_path
          remove_file(path) unless check
        end
      end

      def ensure_output_dir
        FileUtils.mkdir_p(output_dir)
      rescue SystemCallError => e
        raise Error, "Could not create rails_enum_bridge output directory #{output_dir}: #{e.message}"
      end

      def write_file(path, content)
        FileUtils.mkdir_p(path.dirname)
        path.write(content)
        logger&.info("rails_enum_bridge: wrote #{path}")
      rescue SystemCallError => e
        raise Error, "Could not write generated file #{path}: #{e.message}"
      end

      def remove_file(path)
        path.delete
        logger&.info("rails_enum_bridge: removed stale #{path}")
      rescue SystemCallError => e
        raise Error, "Could not remove stale generated file #{path}: #{e.message}"
      end

      def generated_files
        return [] unless output_dir.exist?

        output_dir.glob("**/*.ts").select do |path|
          path.file? && path.read.start_with?(GENERATED_MARKER)
        end
      end

      def default_logger
        defined?(Rails) ? Rails.logger : nil
      end
    end
  end
end
