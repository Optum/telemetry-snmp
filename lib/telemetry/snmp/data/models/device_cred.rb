module Telemetry
  module Snmp
    module Data
      module Model
        class DeviceCred < Sequel::Model
          one_to_many :devices
        end
      end
    end
  end
end
