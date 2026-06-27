# frozen_string_literal: true

module TypedEnums
  module Output
    class Writer
      Result = Data.define(:changed, :missing, :extra, :unchanged, :conflicts) do
        def stale?
          changed.any? || missing.any? || extra.any? || conflicts.any?
        end

        def conflict?
          conflicts.any?
        end

        def summary
          {
            "conflicts" => conflicts,
            "missing" => missing,
            "changed" => changed,
            "extra" => extra
          }.filter_map do |label, files|
            "#{label}: #{files.join(', ')}" if files.any?
          end.join("\n")
        end

        def applied_summary
          {
            "created" => missing,
            "updated" => changed,
            "removed" => extra
          }.filter_map do |label, files|
            "#{label}: #{files.join(', ')}" if files.any?
          end.join("\n")
        end
      end
    end
  end
end
