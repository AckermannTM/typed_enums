# frozen_string_literal: true

require "fileutils"
require "pathname"

module TypedEnums
  module Output
    class Writer
      GENERATED_MARKER = JavaScriptFile::HEADER

      Result = Data.define(:changed, :missing, :extra, :unchanged, :conflicts) do
        def stale?
          changed.any? || missing.any? || extra.any? || conflicts.any?
        end

        def conflict?
          conflicts.any?
        end

        def summary
          {
            "conflicts" => conflicts,
            "missing" => missing,
            "changed" => changed,
            "extra" => extra
          }.filter_map do |label, files|
            "#{label}: #{files.join(', ')}" if files.any?
          end.join("\n")
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

        result = Result.new(changed: [], missing: [], extra: [], unchanged: [], conflicts: [])
        reconcile_expected_files(result)
        reconcile_stale_files(result)
        result
      end

      private

      attr_reader :output_dir, :expected_files, :logger, :check

      def reconcile_expected_files(result)
        expected_files.sort.each do |relative_path, content|
          path = output_dir.join(relative_path)
          reconcile_expected_file(result:, relative_path:, path:, content:)
        end
      end

      def reconcile_expected_file(result:, relative_path:, path:, content:)
        if !path.exist?
          mark_missing(result:, relative_path:, path:, content:)
        elsif path.read == content
          result.unchanged << relative_path
        elsif !generated_file?(path)
          result.conflicts << relative_path
        else
          mark_changed(result:, relative_path:, path:, content:)
        end
      end

      def mark_missing(result:, relative_path:, path:, content:)
        result.missing << relative_path
        write_file(path, content) unless check
      end

      def mark_changed(result:, relative_path:, path:, content:)
        result.changed << relative_path
        write_file(path, content) unless check
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
        raise Error, "Could not create typed_enums output directory #{output_dir}: #{e.message}"
      end

      def write_file(path, content)
        FileUtils.mkdir_p(path.dirname)
        path.write(content)
        logger&.info("typed_enums: wrote #{path}")
      rescue SystemCallError => e
        raise Error, "Could not write generated file #{path}: #{e.message}"
      end

      def remove_file(path)
        path.delete
        logger&.info("typed_enums: removed stale #{path}")
      rescue SystemCallError => e
        raise Error, "Could not remove stale generated file #{path}: #{e.message}"
      end

      def generated_files
        return [] unless output_dir.exist?

        output_dir.glob("**/*").select do |path|
          generated_file?(path)
        end.sort
      end

      def generated_file?(path)
        path.file? && generated_extension?(path) && path.read.start_with?(GENERATED_MARKER)
      end

      def generated_extension?(path)
        [".js", ".ts"].include?(path.extname) || path.to_s.end_with?(".d.ts")
      end

      def default_logger
        defined?(Rails) ? Rails.logger : nil
      end
    end
  end
end
