# frozen_string_literal: true

require "pathname"

module TypedEnums
  class Watcher
    MODEL_FILE_PATTERN = /\.rb\z/
    DEFAULT_LATENCY = 0.25

    class << self
      def start(**options)
        mutex.synchronize do
          return instance if instance&.started?

          @instance = new(**options)
          @instance.start
        end
      end

      def stop
        mutex.synchronize do
          instance&.stop
          @instance = nil
        end
      end

      def started?
        instance&.started? || false
      end

      def run_foreground(**)
        watcher = start(**)
        sleep
      rescue Interrupt
        nil
      ensure
        watcher&.stop
      end

      private

      attr_reader :instance

      def mutex
        @mutex ||= Mutex.new
      end
    end

    def initialize(root: Rails.root, logger: Rails.logger, listener_factory: nil, generator: TypedEnums)
      @root = Pathname(root)
      @logger = logger
      @listener_factory = listener_factory
      @generator = generator
      @started = false
    end

    def start
      return self if started?

      unless watch_path.directory?
        logger&.warn("typed_enums: model watch path does not exist: #{watch_path}")
        return self
      end

      @listener = build_listener
      listener.start
      @started = true
      logger&.info("typed_enums: watching #{watch_path}")
      self
    end

    def stop
      listener&.stop
      @started = false
      self
    end

    def started?
      @started
    end

    private

    attr_reader :root, :logger, :listener, :listener_factory, :generator

    def watch_path
      root.join("app/models")
    end

    def build_listener
      factory = listener_factory || default_listener_factory
      factory.to(watch_path.to_s, only: MODEL_FILE_PATTERN, latency: DEFAULT_LATENCY) do |modified, added, removed|
        regenerate(modified:, added:, removed:)
      end
    end

    def default_listener_factory
      require "listen"
      Listen
    end

    def regenerate(modified:, added:, removed:)
      changed_files = modified + added + removed
      return if changed_files.empty?

      logger&.info("typed_enums: model file changed, regenerating TypeScript enums")
      reload_application
      generate
    rescue StandardError => e
      logger&.error("typed_enums: watch regeneration failed: #{e.class}: #{e.message}")
    end

    def reload_application
      return unless defined?(Rails) && Rails.respond_to?(:application) && Rails.application

      reloader = Rails.application.reloader
      reloader.reload! if reloader.respond_to?(:reload!)
    end

    def generate
      reloader = defined?(Rails) && Rails.respond_to?(:application) && Rails.application&.reloader
      return generator.generate(logger:) unless reloader

      if reloader.respond_to?(:wrap)
        reloader.wrap { generator.generate(logger:) }
      else
        generator.generate(logger:)
      end
    end
  end
end
