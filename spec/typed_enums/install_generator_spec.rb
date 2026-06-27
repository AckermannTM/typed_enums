# frozen_string_literal: true

require "generators/typed_enums/install_generator"

RSpec.describe TypedEnums::InstallGenerator do
  it "defines the expected source root" do
    expect(described_class.source_root).to end_with("lib/generators/typed_enums/templates")
  end

  it "creates the expected generated directory keep file" do
    action = described_class.instance_method(:create_generated_directory)
    source = File.read(action.source_location.first)

    expect(action.source_location.first).to end_with("lib/generators/typed_enums/install_generator.rb")
    expect(source).to include('create_file "app/javascript/lib/.keep", ""')
  end
end
