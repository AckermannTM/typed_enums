# frozen_string_literal: true

require "active_support/core_ext/string/inflections"

module TypedEnums
  class ModelScanner
    def initialize(config: TypedEnums.configuration, name_builder: TypeScript::NameBuilder.new)
      @config = config
      @name_builder = name_builder
    end

    def call
      eager_load_application

      enum_models.flat_map do |model|
        model.defined_enums.sort_by { |attribute_name, _values| attribute_name }.map do |attribute_name, values|
          build_definition(model:, attribute_name:, values:)
        end
      end
    end

    private

    attr_reader :config, :name_builder

    def eager_load_application
      Rails.application.eager_load! if defined?(Rails) && Rails.respond_to?(:application) && Rails.application
    end

    def enum_models
      root_model_class.descendants
                      .reject(&:abstract_class?)
                      .select { |model| model.defined_enums.any? }
                      .sort_by(&:name)
    end

    def root_model_class
      config.root_model_class.to_s.constantize
    rescue NameError => e
      raise ConfigurationError, "Could not find root model class #{config.root_model_class.inspect}: #{e.message}"
    end

    def build_definition(model:, attribute_name:, values:)
      model_export_name = name_builder.model_export_name(model.name)
      rails_mapping_name = name_builder.rails_mapping_name(attribute_name)

      EnumDefinition.new(
        model_name: model.name,
        model_export_name:,
        attribute_name:,
        rails_mapping_name:,
        typescript_property_name: name_builder.property_name(rails_mapping_name),
        typescript_type_name: name_builder.type_name(model_export_name:, rails_mapping_name:),
        values: values.keys.map(&:to_s)
      )
    end
  end
end
