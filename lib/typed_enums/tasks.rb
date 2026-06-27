# frozen_string_literal: true

require "rake"

namespace :typed_enums do
  desc "Generate TypeScript enum modules from Active Record enums"
  task generate: :environment do
    result = TypedEnums.generate
    if result.stale?
      puts "typed_enums: generated files updated"
      puts result.summary
    else
      puts "typed_enums: generated files are current"
    end
  end

  desc "Check whether generated TypeScript enum modules are current"
  task check: :environment do
    result = TypedEnums.check

    if result.stale?
      warn "typed_enums: generated files are stale"
      warn result.summary
      abort "Run bin/rails typed_enums:generate"
    end

    puts "typed_enums: generated files are current"
  end

  desc "Watch Rails model files and regenerate TypeScript enum modules after saves"
  task watch: :environment do
    puts "typed_enums: watching app/models for enum changes"
    TypedEnums::Watcher.run_foreground(logger: Rails.logger)
  end
end
