# frozen_string_literal: true

require "generators/typed_rails_enum_keys/install_generator"

RSpec.describe TypedRailsEnumKeys::InstallGenerator do
  it "defines the expected source root" do
    expect(described_class.source_root).to end_with("lib/generators/typed_rails_enum_keys/templates")
  end
end
