# frozen_string_literal: true

require "active_support/core_ext/string/inflections"

module TypedRailsEnumKeys
  module TypeScript
    class NameBuilder
      def model_export_name(model_name)
        model_name.to_s.split("::").map(&:camelize).join
      end

      def rails_mapping_name(attribute_name)
        attribute_name.to_s.pluralize
      end

      def property_name(rails_mapping_name)
        rails_mapping_name.to_s.camelize(:lower)
      end

      def type_name(model_export_name:, rails_mapping_name:)
        "#{model_export_name}#{rails_mapping_name.to_s.singularize.camelize}"
      end

      def file_name(model_export_name)
        "#{model_export_name}.ts"
      end
    end
  end
end
