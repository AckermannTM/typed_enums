# frozen_string_literal: true

module TypedEnums
  class Registry
    def initialize(scanner: ModelScanner.new, name_builder: TypeScript::NameBuilder.new)
      @scanner = scanner
      @name_builder = name_builder
    end

    def expected_files
      model_groups.transform_keys { |model_export_name| name_builder.file_name(model_export_name) }
                  .transform_values do |definitions|
        TypeScript::ModelFile.new(model_export_name: definitions.first.model_export_name, definitions:).render
      end
                  .merge("index.ts" => index_file)
    end

    private

    attr_reader :scanner, :name_builder

    def model_groups
      @model_groups ||= scanner.call.group_by(&:model_export_name).sort.to_h
    end

    def index_file
      TypeScript::IndexFile.new(model_export_names: model_groups.keys).render
    end
  end
end
