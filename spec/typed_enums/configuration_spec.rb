# frozen_string_literal: true

RSpec.describe TypedEnums::Configuration do
  it "defaults the output directory to app/javascript/lib" do
    config = described_class.new

    expect(config.output_dir).to eq("app/javascript/lib")
  end

  it "defaults development model watching on" do
    config = described_class.new

    expect(config.watch_models_in_development).to be(true)
  end
end
