# frozen_string_literal: true

require "generators/typed_enums/install_generator"

RSpec.describe TypedEnums::InstallGenerator do
  it "defines the expected source root" do
    expect(described_class.source_root).to end_with("lib/generators/typed_enums/templates")
  end
end
