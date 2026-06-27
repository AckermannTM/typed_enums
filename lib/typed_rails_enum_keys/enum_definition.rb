# frozen_string_literal: true

module TypedRailsEnumKeys
  EnumDefinition = Data.define(
    :model_name,
    :model_export_name,
    :attribute_name,
    :rails_mapping_name,
    :typescript_property_name,
    :typescript_type_name,
    :values
  )
end
