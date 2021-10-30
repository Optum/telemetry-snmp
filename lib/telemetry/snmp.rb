# frozen_string_literal: true

require 'telemetry/snmp/version'
require 'telemetry/logger'
require 'telemetry/metrics/parser'
require 'telemetry/snmp/data'
require 'telemetry/snmp/client'
require 'telemetry/snmp/publisher'
require 'telemetry/snmp/collector'
require 'telemetry/snmp/device_collector'

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
        start_expire_devices
        start_collection
      end

      def start_expire_devices
        @expire_devices_task = Concurrent::TimerTask.new(execution_interval: 300, timeout_interval: 10) do
          Telemetry::Snmp::Collector.unlock_expired_devices
        end
        @expire_devices_task.execute
      end

      def stop_expire_devices
        @expire_devices_task.stop
      end

      def start_collection
        @collection_task = Concurrent::TimerTask.new(execution_interval: 10, timeout_interval: 300) do
          Telemetry::Snmp::Collector.loop_devices
        end
        @collection_task.execute
      end

      def stop_collection
        @collection_task.stop
      end
    end
  end
end
