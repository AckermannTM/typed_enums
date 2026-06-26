# frozen_string_literal: true

RSpec.describe RailsEnumBridge::Railtie do
  it "is a Rails railtie" do
    expect(described_class).to be < Rails::Railtie
  end

  describe ".install_development_hooks" do
    let(:reloader) { instance_double("Reloader", to_prepare: nil) }
    let(:application) { instance_double("Application", reloader:) }

    before do
      allow(Rails).to receive(:application).and_return(application)
      allow(RailsEnumBridge).to receive(:watch)
    end

    it "registers generation and starts watching in development" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))

      described_class.install_development_hooks

      expect(reloader).to have_received(:to_prepare)
      expect(RailsEnumBridge).to have_received(:watch)
    end

    it "does not start watching in production" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))

      described_class.install_development_hooks

      expect(RailsEnumBridge).not_to have_received(:watch)
    end

    it "honors the watch configuration" do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
      RailsEnumBridge.configure { |config| config.watch_models_in_development = false }

      described_class.install_development_hooks

      expect(RailsEnumBridge).not_to have_received(:watch)
    end
  end
end
