# frozen_string_literal: true

RSpec.describe RailsEnumBridge::TypeScript::Writer do
  let(:logger) { Logger.new(IO::NULL) }
  let(:header) { RailsEnumBridge::TypeScript::ModelFile::HEADER }

  def with_tmpdir
    Dir.mktmpdir { |dir| yield Pathname(dir) }
  end

  it "writes missing files" do
    with_tmpdir do |dir|
      result = described_class.new(output_dir: dir, expected_files: { "Task.ts" => "#{header}\n" }, logger:).call

      expect(dir.join("Task.ts").read).to eq("#{header}\n")
      expect(result.missing).to eq(["Task.ts"])
    end
  end

  it "does not rewrite unchanged files" do
    with_tmpdir do |dir|
      path = dir.join("Task.ts")
      path.write("#{header}\n")
      before = path.mtime

      result = described_class.new(output_dir: dir, expected_files: { "Task.ts" => "#{header}\n" }, logger:).call

      expect(result.unchanged).to eq(["Task.ts"])
      expect(path.mtime).to eq(before)
    end
  end

  it "updates changed files and removes stale generated files" do
    with_tmpdir do |dir|
      dir.join("Task.ts").write("#{header}\nold")
      dir.join("Old.ts").write("#{header}\nstale")
      dir.join("UserOwned.ts").write("// user file\n")

      result = described_class.new(output_dir: dir, expected_files: { "Task.ts" => "#{header}\nnew" }, logger:).call

      expect(dir.join("Task.ts").read).to eq("#{header}\nnew")
      expect(dir.join("Old.ts")).not_to exist
      expect(dir.join("UserOwned.ts")).to exist
      expect(result.changed).to eq(["Task.ts"])
      expect(result.extra).to eq(["Old.ts"])
    end
  end

  it "reports stale files in check mode without modifying files" do
    with_tmpdir do |dir|
      dir.join("Task.ts").write("#{header}\nold")
      dir.join("Old.ts").write("#{header}\nstale")

      result = described_class.new(
        output_dir: dir,
        expected_files: { "Task.ts" => "#{header}\nnew", "Board.ts" => "#{header}\n" },
        logger:,
        check: true
      ).call

      expect(result).to be_stale
      expect(result.changed).to eq(["Task.ts"])
      expect(result.missing).to eq(["Board.ts"])
      expect(result.extra).to eq(["Old.ts"])
      expect(dir.join("Task.ts").read).to eq("#{header}\nold")
      expect(dir.join("Old.ts")).to exist
      expect(dir.join("Board.ts")).not_to exist
    end
  end
end
