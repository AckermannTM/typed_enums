# frozen_string_literal: true

require "rake"

namespace :typed_enums do
  desc "Generate JavaScript enum module and TypeScript declarations from Active Record enums"
  task generate: :environment do
    result = TypedEnums.generate
    if result.stale?
      puts "typed_enums: generated files updated"
      puts result.summary
    else
      puts "typed_enums: generated files are current"
    end
  end

  desc "Check whether generated enum files are current"
  task check: :environment do
    result = TypedEnums.check

    if result.stale?
      warn "typed_enums: generated files are stale"
      warn result.summary
      abort "Run bin/rails typed_enums:generate"
    end

    puts "typed_enums: generated files are current"
  end

  desc "Watch Rails model files and regenerate enum files after saves"
  task watch: :environment do
    puts "typed_enums: watching app/models for enum changes"
    TypedEnums::Watcher.run_foreground(logger: Rails.logger)
  end
end
