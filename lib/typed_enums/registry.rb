# frozen_string_literal: true

module TypedEnums
  class Registry
    def initialize(scanner: ModelScanner.new)
      @scanner = scanner
    end

    def expected_files
      javascript_file = Output::JavaScriptFile.new(model_groups:)

      {
        "enums.js" => javascript_file.render,
        "enums.d.ts" => Output::TypeDeclarationFile.new(
          model_groups:,
          schema_hash: javascript_file.schema_hash
        ).render
      }
    end

    private

    attr_reader :scanner

    def model_groups
      @model_groups ||= scanner.call.group_by(&:model_export_name).sort.to_h
    end
  end
end
