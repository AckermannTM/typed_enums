# frozen_string_literal: true

require "rake"

RSpec.describe "rails_enum_bridge rake tasks" do
  before do
    Rake.application = Rake::Application.new
    Rake::Task.define_task(:environment)
    load File.expand_path("../../lib/rails_enum_bridge/tasks.rb", __dir__)
  end

  after do
    Rake.application = nil
  end

  it "loads the generate and check tasks" do
    expect(Rake::Task.task_defined?("rails_enum_bridge:generate")).to be(true)
    expect(Rake::Task.task_defined?("rails_enum_bridge:check")).to be(true)
    expect(Rake::Task.task_defined?("rails_enum_bridge:watch")).to be(true)
  end

  it "runs generate" do
    result = RailsEnumBridge::TypeScript::Writer::Result.new(changed: [], missing: [], extra: [],
                                                             unchanged: ["index.ts"])
    allow(RailsEnumBridge).to receive(:generate).and_return(result)

    expect { Rake::Task["rails_enum_bridge:generate"].invoke }.to output(/generated files are current/).to_stdout
  end

  it "fails check when files are stale" do
    result = RailsEnumBridge::TypeScript::Writer::Result.new(changed: ["Task.ts"], missing: [], extra: [],
                                                             unchanged: [])
    allow(RailsEnumBridge).to receive(:check).and_return(result)

    expect { Rake::Task["rails_enum_bridge:check"].invoke }.to raise_error(SystemExit)
      .and output(/generated files are stale/).to_stderr
  end

  it "runs watch in the foreground" do
    allow(Rails).to receive(:logger).and_return(Logger.new(IO::NULL))
    allow(RailsEnumBridge::Watcher).to receive(:run_foreground)

    expect { Rake::Task["rails_enum_bridge:watch"].invoke }.to output(%r{watching app/models}).to_stdout
    expect(RailsEnumBridge::Watcher).to have_received(:run_foreground).with(logger: Rails.logger)
  end
end
