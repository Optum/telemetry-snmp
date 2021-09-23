module Telemetry
  module Snmp
    module Collector
      class << self
        def worker_name
          "#{::Socket.gethostname.tr('.', '_')}.#{::Process.pid}.#{Thread.current.object_id}"
        end

        def loop_devices
          Telemetry::Snmp::Data::Model::Device.where(:active).order(:last_polled).each do |row|
            next if row.values[:last_polled].to_i + row.values[:frequency] > Time.now.to_i
            next if device_locked?(row.values[:id])

            collect(row.values[:id])
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

            row.delete
          end
        end

        def device_locked?(device_id)
          Telemetry::Snmp::Data::Model::DeviceLock.where(device_id: device_id).count.positive?
        end

        def lock_device(device_id)
          return false unless Telemetry::Snmp::Data::Model::DeviceLock[device_id: device_id].nil?

          Telemetry::Snmp::Data::Model::DeviceLock.insert(
            worker_name: worker_name,
            device_id: device_id,
            created: Sequel::CURRENT_TIMESTAMP,
            expires: Sequel::CURRENT_TIMESTAMP
          )
          true
        end

        # noinspection RubyArgCount
        def unlock_device(device_id)
          device = Telemetry::Snmp::Data::Model::DeviceLock[device_id: device_id]
          return true if device.nil?

          device.delete
        end

        def collect(device_id)
          lock_device(device_id)
          row = Telemetry::Snmp::Data::Model::Device[device_id]
          lines = []
          fields = {}
          tags = {
            hostname: row.values[:hostname],
            ip_address: row.values[:ip_address],
            env: row.values[:environment],
            dc: row.values[:datacenter],
            zone: row.values[:zone],
            influxdb_node_group: 'snmp',
            influxdb_database: 'snmp'
          }

          Telemetry::Snmp::Data::Model::OID.each do |oid_row|
            break if @quit

            oid_value = Telemetry::Snmp::Client.oid_value(row[:hostname], oid_row.values[:oid])
            next if oid_value.nil?
            next unless oid_value.is_a?(Integer) || oid_value.is_a?(Float)

            fields[oid_row.values[:name]] =
              "#{Telemetry::Snmp::Client.oid_value(row[:hostname], oid_row.values[:oid])}i"
          rescue StandardError => e
            Telemetry::Logger.error "#{e.class}: #{e.message}"
          end

          lines.push Telemetry::Metrics::Parser.to_line_protocol(
            measurement: 'palo_alto',
            fields: fields,
            tags: tags,
            timestamp: (DateTime.now.strftime('%Q').to_i * 1000 * 1000)
          )

          walker = Telemetry::Snmp::Client.grab_oid_metrics(row.values[:hostname])
          Telemetry::Logger.info "Pushing #{walker.count} lines for #{row.values[:hostname]}" unless walker.empty?
          Telemetry::Snmp::Publisher.push_lines(walker) unless walker.empty?

          row.update(last_polled: Sequel::CURRENT_TIMESTAMP)
          row.save

          Telemetry::Snmp::Publisher.push_lines(lines) unless lines.empty?
          unlock_device(device_id)
        rescue StandardError => e
          Telemetry::Logger.exception(e, level: 'error')
          unlock_device(device_id)
        end
      end
    end
  end
end
