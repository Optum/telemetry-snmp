module Telemetry
  module Snmp
    module Data
      module Model
        class Device < Sequel::Model
          many_to_one :device_cred
          many_to_one :device_lock
        end
      end
    end
  end
end
