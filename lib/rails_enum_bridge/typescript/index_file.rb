# frozen_string_literal: true

module RailsEnumBridge
  module TypeScript
    class IndexFile
      HEADER = ModelFile::HEADER

      def initialize(model_export_names:)
        @model_export_names = model_export_names
      end

      def render
        exports = model_export_names.sort.map { |name| "export * from \"./#{name}\";" }

        "#{([HEADER, ''] + exports).join("\n")}\n"
      end

      private

      attr_reader :model_export_names
    end
  end
end
