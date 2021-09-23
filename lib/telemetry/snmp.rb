# frozen_string_literal: true

require 'telemetry/snmp/version'
require 'telemetry/logger'
require 'telemetry/metrics/parser'
require 'telemetry/snmp/data'
require 'telemetry/snmp/client'
require 'telemetry/snmp/publisher'
require 'telemetry/snmp/collector'

module Telemetry
  module Snmp
    class << self
      def bootstrap
        Telemetry::Logger.setup(level: 'info')
        Telemetry::Logger.info "Starting Telemetry::Snmp v#{Telemetry::Snmp::VERSION}"
        Telemetry::Snmp::Data.start!
        Telemetry::Snmp::Client.load_mibs
        Telemetry::Snmp::Publisher.start!
        Telemetry::Logger.info 'Telemetry::Snmp bootstrapped!'
      end
    end
  end
end
