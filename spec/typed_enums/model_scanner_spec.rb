# frozen_string_literal: true

RSpec.describe TypedEnums::ModelScanner do
  class ScannerSpecApplicationRecord
    class << self
      attr_accessor :descendant_models

      def descendants
        descendant_models
      end
    end
  end

  FakeModel = Struct.new(:name, :abstract, :enums, keyword_init: true) do
    def abstract_class?
      abstract
    end

    def defined_enums
      enums
    end
  end

  before do
    stub_const("ApplicationRecord", ScannerSpecApplicationRecord)

    TypedEnums.configure do |config|
      config.root_model_class = "ApplicationRecord"
    end
  end

  it "finds enums, skips abstract/no-enum models, preserves values, and orders deterministically" do
    abstract_model = FakeModel.new(name: "AbstractThing", abstract: true, enums: { "state" => { "draft" => 0 } })
    user_model = FakeModel.new(name: "User", abstract: false, enums: {})
    task_model = FakeModel.new(
      name: "Task",
      abstract: false,
      enums: {
        "work_priority" => { "priority_1" => 0, "priority_2" => 1 },
        "ticket_status" => { "to_discuss" => 0, "discussed" => 1 }
      }
    )
    board_column_model = FakeModel.new(
      name: "BoardColumn",
      abstract: false,
      enums: { "ticket_status_mapping" => { "to_discuss" => 0 } }
    )

    ScannerSpecApplicationRecord.descendant_models = [user_model, task_model, abstract_model, board_column_model]

    definitions = described_class.new.call

    expect(definitions.map(&:model_export_name)).to eq(%w[BoardColumn Task Task])
    expect(definitions.map(&:attribute_name)).to eq(%w[ticket_status_mapping ticket_status work_priority])
    expect(definitions.last.values).to eq(%w[priority_1 priority_2])
    expect(definitions.last.rails_mapping_name).to eq("work_priorities")
    expect(definitions.last.typescript_property_name).to eq("workPriorities")
  end

  it "raises a clear error when the root model class is missing" do
    TypedEnums.configure { |config| config.root_model_class = "MissingRecord" }

    expect { described_class.new.call }.to raise_error(TypedEnums::ConfigurationError, /MissingRecord/)
  end
end
