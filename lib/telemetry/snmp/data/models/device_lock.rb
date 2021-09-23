module Telemetry
  module Snmp
    module Data
      module Model
        class DeviceLock < Sequel::Model
          one_to_one :device
        end
      end
    end
  end
end
