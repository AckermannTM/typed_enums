# frozen_string_literal: true

RSpec.describe TypedEnums::Registry do
  it "builds one JavaScript module and one TypeScript declaration file" do
    definition = TypedEnums::EnumDefinition.new(
      model_name: "Task",
      model_export_name: "Task",
      attribute_name: "work_priority",
      rails_mapping_name: "work_priorities",
      typescript_property_name: "workPriorities",
      typescript_type_name: "TaskWorkPriority",
      values: %w[priority_1 priority_2]
    )
    scanner = instance_double(TypedEnums::ModelScanner, call: [definition])

    files = described_class.new(scanner:).expected_files

    expect(files.keys).to eq(["enums.js", "enums.d.ts"])
    expect(files["enums.js"]).to include("export const Task = {")
    expect(files["enums.d.ts"]).to include("export type TaskWorkPriority")
  end
end
