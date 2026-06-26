# frozen_string_literal: true

require "generators/rails_enum_bridge/install_generator"

RSpec.describe RailsEnumBridge::InstallGenerator do
  it "defines the expected source root" do
    expect(described_class.source_root).to end_with("lib/generators/rails_enum_bridge/templates")
  end
end
