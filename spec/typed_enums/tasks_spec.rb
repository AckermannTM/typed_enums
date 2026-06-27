# frozen_string_literal: true

require "rake"

RSpec.describe "typed_enums rake tasks" do
  before do
    Rake.application = Rake::Application.new
    Rake::Task.define_task(:environment)
    load File.expand_path("../../lib/typed_enums/tasks.rb", __dir__)
  end

  after do
    Rake.application = nil
  end

  it "loads the generate and check tasks" do
    expect(Rake::Task.task_defined?("typed_enums:generate")).to be(true)
    expect(Rake::Task.task_defined?("typed_enums:check")).to be(true)
    expect(Rake::Task.task_defined?("typed_enums:watch")).to be(true)
  end

  it "runs generate" do
    result = TypedEnums::Output::Writer::Result.new(changed: [], missing: [], extra: [],
                                                    unchanged: ["enums.js", "enums.d.ts"], conflicts: [])
    allow(TypedEnums).to receive(:generate).and_return(result)

    expect { Rake::Task["typed_enums:generate"].invoke }.to output(/generated files are current/).to_stdout
  end

  it "reports generated files created on first generate" do
    result = TypedEnums::Output::Writer::Result.new(changed: [], missing: ["enums.d.ts", "enums.js"], extra: [],
                                                    unchanged: [], conflicts: [])
    allow(TypedEnums).to receive(:generate).and_return(result)

    expect { Rake::Task["typed_enums:generate"].invoke }.to output(
      /generated files updated\ncreated: enums.d.ts, enums.js/
    ).to_stdout
  end

  it "fails check when files are stale" do
    result = TypedEnums::Output::Writer::Result.new(changed: ["enums.js"], missing: [], extra: [],
                                                    unchanged: [], conflicts: [])
    allow(TypedEnums).to receive(:check).and_return(result)

    expect { Rake::Task["typed_enums:check"].invoke }.to raise_error(SystemExit)
      .and output(/generated files are stale/).to_stderr
  end

  it "fails generate when output files conflict with user-owned files" do
    result = TypedEnums::Output::Writer::Result.new(changed: [], missing: [], extra: [], unchanged: [],
                                                    conflicts: ["enums.js"])
    allow(TypedEnums).to receive(:generate).and_return(result)

    expect { Rake::Task["typed_enums:generate"].invoke }.to raise_error(SystemExit)
      .and output(/refusing to overwrite existing non-generated files/).to_stderr
  end

  it "fails check when output files conflict with user-owned files" do
    result = TypedEnums::Output::Writer::Result.new(changed: [], missing: [], extra: [], unchanged: [],
                                                    conflicts: ["enums.d.ts"])
    allow(TypedEnums).to receive(:check).and_return(result)

    expect { Rake::Task["typed_enums:check"].invoke }.to raise_error(SystemExit)
      .and output(/existing non-generated files block enum generation/).to_stderr
  end

  it "runs watch in the foreground" do
    allow(Rails).to receive(:logger).and_return(Logger.new(IO::NULL))
    allow(TypedEnums::Watcher).to receive(:run_foreground)

    expect { Rake::Task["typed_enums:watch"].invoke }.to output(%r{watching app/models}).to_stdout
    expect(TypedEnums::Watcher).to have_received(:run_foreground).with(logger: Rails.logger)
  end
end
