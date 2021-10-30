module Telemetry
  module Snmp
    class DeviceCollector
      include Concurrent::Async

      def initialize(host)
        @device = Telemetry::Snmp::Data::Model::Device.where(hostname: host).or(ip_address: host).first
        return if @device.nil?

        @id = @device.values[:id]
        @hostname = @device.values[:hostname]
      end

      def connection
        @connection ||= NETSNMP::Client.new(
          host: @device.values[:hostname],
          port: @device.values[:port],
          username: @device.device_cred.values[:username],
          auth_password: @device.device_cred.values[:auth_password],
          auth_protocol: @device.device_cred.values[:auth_protocol].to_sym,
          priv_password: @device.device_cred.values[:priv_password],
          priv_protocol: @device.device_cred.values[:priv_protocol].to_sym,
          security_level: @device.device_cred.values[:security_level].to_sym
        )
      end

      def collect
        return false unless lock_device

        @collection_start = Time.now

        @device.update(last_polled: Sequel::CURRENT_TIMESTAMP)
        @device.save
        @lines = []
        @fields = {}

        Telemetry::Snmp::Data::Model::OID.where(:active).each do |oid_row|
          oid_value = oid_value(oid_row.values[:oid])
          oid_value = oid_value.to_i if oid_value.is_a?(NETSNMP::Timetick)

          if oid_value.nil?
            Telemetry::Logger.warn "#{@hostname} nil result for #{oid_row.values[:oid]}"
            next
          end

          unless oid_value.is_a?(Integer) || oid_value.is_a?(Float)
            Telemetry::Logger.error "#{@hostname} nil result for #{oid_row.values[:oid]} class: #{oid_value.class}, #{oid_value}" # rubocop:disable Layout/LineLength
            next
          end

          @fields[oid_row.values[:name]] =
            "#{oid_value}i"
        rescue StandardError => e
          Telemetry::Logger.error "#{e.class}: #{e.message}"
        end

        @lines.push Telemetry::Metrics::Parser.to_line_protocol(
          measurement: 'palo_alto',
          fields: @fields,
          tags: tags,
          timestamp: (DateTime.now.strftime('%Q').to_i * 1000 * 1000)
        )

        walker = grab_oid_metrics
        unless walker.empty?
          Telemetry::Logger.info "Pushing #{walker.count} lines for #{@hostname} in #{((Time.now - @collection_start) * 1000).round}ms" # rubocop:disable Layout/LineLength
        end
        Telemetry::Snmp::Publisher.push_lines(walker) unless walker.empty?
        Telemetry::Snmp::Publisher.push_lines(@lines) unless @lines.empty?
        unlock_device
      rescue StandardError => e
        Telemetry::Logger.exception(e, level: 'error')
        unlock_device
      end

      def oid_value(oid)
        connection.get(oid: oid)
      rescue StandardError
        nil
      end

      def oid_walk(oid)
        results = []
        connection.walk(oid: oid).each do |oid_code, value|
          hash = { oid_code: oid_code, value: value }
          begin
            ident = NETSNMP::MIB.identifier(oid_code)

            hash[:identifier] = ident.first
          rescue StandardError
            # literally do nothing
          end
          results.push hash
        end

        results
      end

      def grab_oid_metrics
        @lines = []
        Telemetry::Snmp::Data::Model::OIDWalks.where(:active).each do |row|
          index = {}
          oid_walk(row.values[:oid_index]).each do |hash|
            index[hash[:oid_code].delete_prefix("#{row.values[:oid_index]}.")] = hash[:value].gsub(%r{\\/}, '.')
          end

          timestamp = DateTime.now.strftime('%Q').to_i * 1000 * 1000
          oid_walk(row.values[:oid_walk]).each do |walk|
            key = walk[:oid_code].split('.').last
            next if walk[:value].is_a? String
            next if walk[:value].nil?

            fields = {}
            fields[walk[:identifier]] = "#{walk[:value]}i"
            tags = {
              hostname: @hostname,
              interface: index[key],
              ip_address: @device.values[:ip_address],
              zone: @device.values[:zone],
              env: @device.values[:environment],
              dc: @device.values[:datacenter],
              influxdb_node_group: 'snmp',
              influxdb_database: 'snmp'
            }

            line = Telemetry::Metrics::Parser.to_line_protocol(
              measurement: row.values[:measurement_name],
              fields: fields,
              tags: tags,
              timestamp: timestamp
            )

            @lines.push line
          end
        rescue StandardError => e
          Telemetry::Logger.error "#{e.class}: #{@hostname}, #{e.message}"
        end

        @lines
      end

      def device_locked?
        Telemetry::Snmp::Data::Model::DeviceLock.where(device_id: @id).count.positive?
      end

      def device_unlocked?
        Telemetry::Snmp::Data::Model::DeviceLock.where(device_id: @id).count.zero?
      end

      def lock_device
        Telemetry::Snmp::Data::Model::DeviceLock.insert(
          worker_name: worker_name,
          device_id: @id,
          created: Sequel::CURRENT_TIMESTAMP,
          expires: Sequel::CURRENT_TIMESTAMP
        )
        true
      end

      def tags
        tags = {
          hostname: @device.values[:hostname],
          ip_address: @device.values[:ip_address],
          env: @device.values[:environment],
          dc: @device.values[:datacenter],
          zone: @device.values[:zone],
          influxdb_node_group: 'snmp',
          influxdb_database: 'snmp'
        }
        tags.delete_if { |_k, v| v.nil? }

        tags
      end

      def unlock_device
        device = Telemetry::Snmp::Data::Model::DeviceLock[device_id: @id]
        return true if device.nil?

        device.delete
      end

      def worker_name
        "#{::Socket.gethostname.tr('.', '_')}.#{::Process.pid}.#{Thread.current.object_id}"
      end
    end
  end
end
