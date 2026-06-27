# frozen_string_literal: true

require "rake"

RSpec.describe "typed_rails_enum_keys rake tasks" do
  before do
    Rake.application = Rake::Application.new
    Rake::Task.define_task(:environment)
    load File.expand_path("../../lib/typed_rails_enum_keys/tasks.rb", __dir__)
  end

  after do
    Rake.application = nil
  end

  it "loads the generate and check tasks" do
    expect(Rake::Task.task_defined?("typed_rails_enum_keys:generate")).to be(true)
    expect(Rake::Task.task_defined?("typed_rails_enum_keys:check")).to be(true)
    expect(Rake::Task.task_defined?("typed_rails_enum_keys:watch")).to be(true)
  end

  it "runs generate" do
    result = TypedRailsEnumKeys::TypeScript::Writer::Result.new(changed: [], missing: [], extra: [],
                                                                unchanged: ["index.ts"])
    allow(TypedRailsEnumKeys).to receive(:generate).and_return(result)

    expect { Rake::Task["typed_rails_enum_keys:generate"].invoke }.to output(/generated files are current/).to_stdout
  end

  it "fails check when files are stale" do
    result = TypedRailsEnumKeys::TypeScript::Writer::Result.new(changed: ["Task.ts"], missing: [], extra: [],
                                                                unchanged: [])
    allow(TypedRailsEnumKeys).to receive(:check).and_return(result)

    expect { Rake::Task["typed_rails_enum_keys:check"].invoke }.to raise_error(SystemExit)
      .and output(/generated files are stale/).to_stderr
  end

  it "runs watch in the foreground" do
    allow(Rails).to receive(:logger).and_return(Logger.new(IO::NULL))
    allow(TypedRailsEnumKeys::Watcher).to receive(:run_foreground)

    expect { Rake::Task["typed_rails_enum_keys:watch"].invoke }.to output(%r{watching app/models}).to_stdout
    expect(TypedRailsEnumKeys::Watcher).to have_received(:run_foreground).with(logger: Rails.logger)
  end
end
