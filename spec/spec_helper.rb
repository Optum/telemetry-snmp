require 'telemetry/logger'
Telemetry::Logger.setup(level: 'error')

require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
end
require 'telemetry/snmp'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
