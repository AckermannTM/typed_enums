# frozen_string_literal: true

RSpec.describe TypedRailsEnumKeys::TypeScript::NameBuilder do
  subject(:builder) { described_class.new }

  it "converts Rails plural mapping names to camelCase properties" do
    expect(builder.property_name("work_priorities")).to eq("workPriorities")
    expect(builder.property_name("ticket_statuses")).to eq("ticketStatuses")
    expect(builder.property_name("fix_priorities")).to eq("fixPriorities")
    expect(builder.property_name("severities")).to eq("severities")
    expect(builder.property_name("urgencies")).to eq("urgencies")
  end

  it "pluralizes enum attributes like Rails mapping methods" do
    expect(builder.rails_mapping_name("work_priority")).to eq("work_priorities")
    expect(builder.rails_mapping_name("ticket_status")).to eq("ticket_statuses")
    expect(builder.rails_mapping_name("severity")).to eq("severities")
    expect(builder.rails_mapping_name("urgency")).to eq("urgencies")
  end

  it "generates singular model-prefixed type names" do
    expect(builder.type_name(model_export_name: "Task",
                             rails_mapping_name: "work_priorities")).to eq("TaskWorkPriority")
    expect(builder.type_name(model_export_name: "Task",
                             rails_mapping_name: "ticket_statuses")).to eq("TaskTicketStatus")
    expect(builder.type_name(model_export_name: "Task", rails_mapping_name: "fix_priorities")).to eq("TaskFixPriority")
    expect(builder.type_name(model_export_name: "Task", rails_mapping_name: "severities")).to eq("TaskSeverity")
    expect(builder.type_name(model_export_name: "Task", rails_mapping_name: "urgencies")).to eq("TaskUrgency")
  end

  it "flattens namespaced model names into safe exports" do
    expect(builder.model_export_name("Admin::Task")).to eq("AdminTask")
    expect(builder.file_name("AdminTask")).to eq("AdminTask.ts")
  end
end
