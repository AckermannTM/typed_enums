# frozen_string_literal: true

require "json"

module TypedEnums
  module Output
    class TypeDeclarationFile
      HEADER = JavaScriptFile::HEADER

      def initialize(model_groups:, schema_hash:)
        @model_groups = model_groups
        @schema_hash = schema_hash
      end

      def render
        <<~TYPESCRIPT
          #{HEADER}
          // enum-schema-sha256: #{schema_hash}

          #{declarations}
        TYPESCRIPT
      end

      private

      attr_reader :model_groups, :schema_hash

      def declarations
        model_groups.map do |model_export_name, definitions|
          [constant_declaration(model_export_name, definitions), type_declarations(definitions)].join("\n\n")
        end.join("\n\n")
      end

      def constant_declaration(model_export_name, definitions)
        <<~TYPESCRIPT.chomp
          export declare const #{model_export_name}: {
          #{property_lines(definitions)}
          };
        TYPESCRIPT
      end

      def property_lines(definitions)
        definitions.map do |definition|
          "  readonly #{definition.typescript_property_name}: readonly #{render_tuple(definition.values)};"
        end.join("\n")
      end

      def type_declarations(definitions)
        definitions.map do |definition|
          "export type #{definition.typescript_type_name} = " \
            "(typeof #{definition.model_export_name}.#{definition.typescript_property_name})[number];"
        end.join("\n")
      end

      def render_tuple(values)
        "[#{values.map { |value| JSON.generate(value) }.join(', ')}]"
      end
    end
  end
end
