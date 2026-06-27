# frozen_string_literal: true

RSpec.describe TypedEnums::Output::Writer do
  let(:logger) { Logger.new(IO::NULL) }
  let(:header) { TypedEnums::Output::JavaScriptFile::HEADER }

  def with_tmpdir
    Dir.mktmpdir { |dir| yield Pathname(dir) }
  end

  it "writes missing files" do
    with_tmpdir do |dir|
      result = described_class.new(output_dir: dir, expected_files: { "enums.js" => "#{header}\n" }, logger:).call

      expect(dir.join("enums.js").read).to eq("#{header}\n")
      expect(result.missing).to eq(["enums.js"])
    end
  end

  it "does not rewrite unchanged files" do
    with_tmpdir do |dir|
      path = dir.join("enums.js")
      path.write("#{header}\n")
      before = path.mtime

      result = described_class.new(output_dir: dir, expected_files: { "enums.js" => "#{header}\n" }, logger:).call

      expect(result.unchanged).to eq(["enums.js"])
      expect(path.mtime).to eq(before)
    end
  end

  it "updates changed files and removes stale generated files" do
    with_tmpdir do |dir|
      dir.join("enums.js").write("#{header}\nold")
      dir.join("enums.d.ts").write("#{header}\nstale")
      dir.join("index.js").write("#{header}\nstale")
      dir.join("index.d.ts").write("#{header}\nstale")
      dir.join("Task.ts").write("#{header}\nlegacy")
      dir.join("UserOwned.ts").write("// user file\n")

      result = described_class.new(output_dir: dir, expected_files: { "enums.js" => "#{header}\nnew" }, logger:).call

      expect(dir.join("enums.js").read).to eq("#{header}\nnew")
      expect(dir.join("enums.d.ts")).not_to exist
      expect(dir.join("index.js")).not_to exist
      expect(dir.join("index.d.ts")).not_to exist
      expect(dir.join("Task.ts")).not_to exist
      expect(dir.join("UserOwned.ts")).to exist
      expect(result.changed).to eq(["enums.js"])
      expect(result.extra).to eq(["Task.ts", "enums.d.ts", "index.d.ts", "index.js"])
    end
  end

  it "does not overwrite existing non-generated output files" do
    with_tmpdir do |dir|
      dir.join("enums.js").write("// user-owned enums\n")

      result = described_class.new(output_dir: dir, expected_files: { "enums.js" => "#{header}\nnew" }, logger:).call

      expect(result).to be_conflict
      expect(result.conflicts).to eq(["enums.js"])
      expect(dir.join("enums.js").read).to eq("// user-owned enums\n")
    end
  end

  it "reports non-generated output file conflicts in check mode" do
    with_tmpdir do |dir|
      dir.join("enums.d.ts").write("// user-owned declarations\n")

      result = described_class.new(
        output_dir: dir,
        expected_files: { "enums.d.ts" => "#{header}\nnew" },
        logger:,
        check: true
      ).call

      expect(result).to be_conflict
      expect(result.conflicts).to eq(["enums.d.ts"])
      expect(dir.join("enums.d.ts").read).to eq("// user-owned declarations\n")
    end
  end

  it "reports stale files in check mode without modifying files" do
    with_tmpdir do |dir|
      dir.join("enums.js").write("#{header}\nold")
      dir.join("Task.ts").write("#{header}\nstale")

      result = described_class.new(
        output_dir: dir,
        expected_files: { "enums.js" => "#{header}\nnew", "enums.d.ts" => "#{header}\n" },
        logger:,
        check: true
      ).call

      expect(result).to be_stale
      expect(result.changed).to eq(["enums.js"])
      expect(result.missing).to eq(["enums.d.ts"])
      expect(result.extra).to eq(["Task.ts"])
      expect(dir.join("enums.js").read).to eq("#{header}\nold")
      expect(dir.join("Task.ts")).to exist
      expect(dir.join("enums.d.ts")).not_to exist
    end
  end

  it "summarizes applied generate actions separately from stale check state" do
    result = described_class::Result.new(
      changed: ["enums.js"],
      missing: ["enums.d.ts"],
      extra: ["Task.ts"],
      unchanged: [],
      conflicts: []
    )

    expect(result.summary).to eq("missing: enums.d.ts\nchanged: enums.js\nextra: Task.ts")
    expect(result.applied_summary).to eq("created: enums.d.ts\nupdated: enums.js\nremoved: Task.ts")
  end
end
