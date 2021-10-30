module Telemetry
  module Snmp
    module Collector
      class << self
        def loop_devices
          count = 0
          Telemetry::Snmp::Data::Model::Device.where(:active).order(:last_polled).each do |row|
            break if count >= 10
            next if row.values[:last_polled].to_i + row.values[:frequency] > Time.now.to_i
            next if device_locked?(row.values[:id])

            Telemetry::Logger.info "Grabbing metrics for #{row.values[:hostname]}"
            device = Telemetry::Snmp::DeviceCollector.new(row.values[:hostname])
            device.async.collect
            count += 1
          end
        end

        def poll_next_device
          Telemetry::Snmp::Data::Model::Device.where(:active).order(:last_polled).each do |row|
            next if row.values[:last_polled].to_i + row.values[:frequency] > Time.now.to_i
            next if device_locked?(row.values[:id])

            Telemetry::Logger.info "Grabbing metrics for #{row.values[:hostname]}"
            collect(row.values[:id])
            break
          rescue StandardError => e
            Telemetry::Logger.exception(e, level: 'error')
          end
        end

        def unlock_expired_devices
          Telemetry::Snmp::Data::Model::DeviceLock.each do |row|
            next if row.values[:expires] < Sequel::CURRENT_TIMESTAMP

            Telemetry::Logger.warn "removing lock for #{row.values[:hostname]}"
            row.delete
          end
        end

        def device_locked?(device_id)
          Telemetry::Snmp::Data::Model::DeviceLock.where(device_id: device_id).count.positive?
        end

        def device_unlocked?(device_id)
          !device_locked?(device_id)
        end
      end
    end
  end
end
