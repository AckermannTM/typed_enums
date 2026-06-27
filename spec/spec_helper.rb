# frozen_string_literal: true

require "tmpdir"
require "logger"
require "active_support/core_ext/module/delegation"
require "rails/railtie"

require "typed_rails_enum_keys"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.before do
    TypedRailsEnumKeys.reset_configuration!
  end
end
