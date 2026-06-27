# frozen_string_literal: true

RSpec.describe TypedRailsEnumKeys::Configuration do
  it "defaults development model watching on" do
    config = described_class.new

    expect(config.watch_models_in_development).to be(true)
  end
end
