module Telemetry
  module Snmp
    module Data
      module Model
        class UserAuditLog < Sequel::Model
          plugin :serialization
          serialize_attributes :json, :entry

          many_to_one :user

          many_to_one :device
          many_to_one :device_cred
          many_to_one :oid
          many_to_one :oid_walk
        end
      end
    end
  end
end
