# frozen_string_literal: true

RSpec.describe TypedEnums::Output::Writer do
  let(:logger) { Logger.new(IO::NULL) }
  let(:header) { TypedEnums::Output::JavaScriptFile::HEADER }

  def with_tmpdir
    Dir.mktmpdir { |dir| yield Pathname(dir) }
  end

  it "writes missing files" do
    with_tmpdir do |dir|
      result = described_class.new(output_dir: dir, expected_files: { "index.js" => "#{header}\n" }, logger:).call

      expect(dir.join("index.js").read).to eq("#{header}\n")
      expect(result.missing).to eq(["index.js"])
    end
  end

  it "does not rewrite unchanged files" do
    with_tmpdir do |dir|
      path = dir.join("index.js")
      path.write("#{header}\n")
      before = path.mtime

      result = described_class.new(output_dir: dir, expected_files: { "index.js" => "#{header}\n" }, logger:).call

      expect(result.unchanged).to eq(["index.js"])
      expect(path.mtime).to eq(before)
    end
  end

  it "updates changed files and removes stale generated files" do
    with_tmpdir do |dir|
      dir.join("index.js").write("#{header}\nold")
      dir.join("index.d.ts").write("#{header}\nstale")
      dir.join("Task.ts").write("#{header}\nlegacy")
      dir.join("UserOwned.ts").write("// user file\n")

      result = described_class.new(output_dir: dir, expected_files: { "index.js" => "#{header}\nnew" }, logger:).call

      expect(dir.join("index.js").read).to eq("#{header}\nnew")
      expect(dir.join("index.d.ts")).not_to exist
      expect(dir.join("Task.ts")).not_to exist
      expect(dir.join("UserOwned.ts")).to exist
      expect(result.changed).to eq(["index.js"])
      expect(result.extra).to eq(["Task.ts", "index.d.ts"])
    end
  end

  it "reports stale files in check mode without modifying files" do
    with_tmpdir do |dir|
      dir.join("index.js").write("#{header}\nold")
      dir.join("Task.ts").write("#{header}\nstale")

      result = described_class.new(
        output_dir: dir,
        expected_files: { "index.js" => "#{header}\nnew", "index.d.ts" => "#{header}\n" },
        logger:,
        check: true
      ).call

      expect(result).to be_stale
      expect(result.changed).to eq(["index.js"])
      expect(result.missing).to eq(["index.d.ts"])
      expect(result.extra).to eq(["Task.ts"])
      expect(dir.join("index.js").read).to eq("#{header}\nold")
      expect(dir.join("Task.ts")).to exist
      expect(dir.join("index.d.ts")).not_to exist
    end
  end
end
