# frozen_string_literal: true

require "rake"

namespace :rails_enum_bridge do
  desc "Generate TypeScript enum modules from Active Record enums"
  task generate: :environment do
    result = RailsEnumBridge.generate
    if result.stale?
      puts "rails_enum_bridge: generated files updated"
      puts result.summary
    else
      puts "rails_enum_bridge: generated files are current"
    end
  end

  desc "Check whether generated TypeScript enum modules are current"
  task check: :environment do
    result = RailsEnumBridge.check

    if result.stale?
      warn "rails_enum_bridge: generated files are stale"
      warn result.summary
      abort "Run bin/rails rails_enum_bridge:generate"
    end

    puts "rails_enum_bridge: generated files are current"
  end

  desc "Watch Rails model files and regenerate TypeScript enum modules after saves"
  task watch: :environment do
    puts "rails_enum_bridge: watching app/models for enum changes"
    RailsEnumBridge::Watcher.run_foreground(logger: Rails.logger)
  end
end
