# frozen_string_literal: true

RSpec.describe TypedRailsEnumKeys::Watcher do
  FakeListener = Struct.new(:callback, :started, keyword_init: true) do
    def start
      self.started = true
    end

    def stop
      self.started = false
    end
  end

  class FakeListenerFactory
    attr_reader :path, :options, :listener

    def to(path, **options, &block)
      @path = path
      @options = options
      @listener = FakeListener.new(callback: block, started: false)
    end
  end

  let(:logger) { Logger.new(IO::NULL) }
  let(:generator) { class_double(TypedRailsEnumKeys, generate: nil) }

  def with_model_dir
    Dir.mktmpdir do |dir|
      root = Pathname(dir)
      FileUtils.mkdir_p(root.join("app/models"))
      yield root
    end
  end

  after do
    described_class.stop
  end

  it "starts a listener for Rails model files" do
    with_model_dir do |root|
      factory = FakeListenerFactory.new
      watcher = described_class.new(root:, logger:, listener_factory: factory, generator:)

      watcher.start

      expect(watcher).to be_started
      expect(factory.path).to eq(root.join("app/models").to_s)
      expect(factory.options).to include(only: described_class::MODEL_FILE_PATTERN)
      expect(factory.listener.started).to be(true)
    end
  end

  it "regenerates when model files change" do
    with_model_dir do |root|
      factory = FakeListenerFactory.new
      watcher = described_class.new(root:, logger:, listener_factory: factory, generator:)
      watcher.start

      factory.listener.callback.call([root.join("app/models/task.rb").to_s], [], [])

      expect(generator).to have_received(:generate).with(logger:)
    end
  end

  it "does not regenerate when a listener event has no changed files" do
    with_model_dir do |root|
      factory = FakeListenerFactory.new
      watcher = described_class.new(root:, logger:, listener_factory: factory, generator:)
      watcher.start

      factory.listener.callback.call([], [], [])

      expect(generator).not_to have_received(:generate)
    end
  end

  it "reloads Rails application code before generating when a reloader is available" do
    with_model_dir do |root|
      factory = FakeListenerFactory.new
      reloader = instance_double("Reloader")
      application = instance_double("Application", reloader:)
      allow(Rails).to receive(:respond_to?).and_call_original
      allow(Rails).to receive(:respond_to?).with(:application).and_return(true)
      allow(Rails).to receive(:application).and_return(application)
      allow(reloader).to receive(:reload!)
      allow(reloader).to receive(:wrap).and_yield

      watcher = described_class.new(root:, logger:, listener_factory: factory, generator:)
      watcher.start
      factory.listener.callback.call([root.join("app/models/task.rb").to_s], [], [])

      expect(reloader).to have_received(:reload!)
      expect(generator).to have_received(:generate).with(logger:)
    end
  end

  it "keeps class-level startup idempotent" do
    with_model_dir do |root|
      factory = FakeListenerFactory.new
      first = described_class.start(root:, logger:, listener_factory: factory, generator:)
      second = described_class.start(root:, logger:, listener_factory: factory, generator:)

      expect(second).to equal(first)
    end
  end
end
