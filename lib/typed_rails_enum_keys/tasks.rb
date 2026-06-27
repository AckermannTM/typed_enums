# frozen_string_literal: true

require "rake"

namespace :typed_rails_enum_keys do
  desc "Generate TypeScript enum modules from Active Record enums"
  task generate: :environment do
    result = TypedRailsEnumKeys.generate
    if result.stale?
      puts "typed_rails_enum_keys: generated files updated"
      puts result.summary
    else
      puts "typed_rails_enum_keys: generated files are current"
    end
  end

  desc "Check whether generated TypeScript enum modules are current"
  task check: :environment do
    result = TypedRailsEnumKeys.check

    if result.stale?
      warn "typed_rails_enum_keys: generated files are stale"
      warn result.summary
      abort "Run bin/rails typed_rails_enum_keys:generate"
    end

    puts "typed_rails_enum_keys: generated files are current"
  end

  desc "Watch Rails model files and regenerate TypeScript enum modules after saves"
  task watch: :environment do
    puts "typed_rails_enum_keys: watching app/models for enum changes"
    TypedRailsEnumKeys::Watcher.run_foreground(logger: Rails.logger)
  end
end
