require 'socket'
require 'netsnmp'

module Telemetry
  module Snmp
    module Client
      @connections = {}

      class << self
        def load_mibs
          ENV['MIBDIRS'] = "#{__dir__}/mibs"
          NETSNMP::MIB.load_defaults
          # NETSNMP::MIB.load("#{__dir__}/mibs/PAN-COMMON-MIB.my")
          # NETSNMP::MIB.load("#{__dir__}/mibs/PAN-ENTITY-EXT-MIB.my")
          # NETSNMP::MIB.load("#{__dir__}/mibs/PAN-GLOBAL-REG-MIB.my")
          # NETSNMP::MIB.load("#{__dir__}/mibs/PAN-GLOBAL-TC-MIB.my")
          # NETSNMP::MIB.load("#{__dir__}/mibs/PAN-LC-MIB.my")
          # NETSNMP::MIB.load("#{__dir__}/mibs/PAN-PRODUCT-MIB.my")
        end

        def connection(host)
          return @connections[host.to_sym] if @connections.key? host.to_sym

          dataset = Telemetry::Snmp::Data::Model::Device.where(hostname: host).or(ip_address: host).first

          @connections[host.to_sym] = NETSNMP::Client.new(
            host: dataset.values[:hostname],
            port: dataset.values[:port],
            username: dataset.device_cred.values[:username],
            auth_password: dataset.device_cred.values[:auth_password],
            auth_protocol: dataset.device_cred.values[:auth_protocol].to_sym,
            priv_password: dataset.device_cred.values[:priv_password],
            priv_protocol: dataset.device_cred.values[:priv_protocol].to_sym,
            security_level: dataset.device_cred.values[:security_level].to_sym
          )
        end

        def oid_value(host, oid)
          connection(host).get(oid: oid)
        rescue StandardError
          nil
        end

        def oid_walk(host, oid)
          results = []
          connection(host).walk(oid: oid).each do |oid_code, value|
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

        def grab_oid_metrics(hostname)
          device = Telemetry::Snmp::Data::Model::Device.where(hostname: hostname).or(ip_address: hostname).first
          @lines = []
          Telemetry::Snmp::Data::Model::OIDWalks.where(:active).each do |row|
            index = {}
            Telemetry::Snmp::Client.oid_walk(device.values[:hostname], row.values[:oid_index]).each do |hash|
              index[hash[:oid_code].delete_prefix("#{row.values[:oid_index]}.")] = hash[:value].gsub(%r{\\/}, '.')
            end

            timestamp = DateTime.now.strftime('%Q').to_i * 1000 * 1000
            Telemetry::Snmp::Client.oid_walk(device.values[:hostname], row.values[:oid_walk]).each do |walk|
              key = walk[:oid_code].split('.').last
              next if walk[:value].is_a? String
              next if walk[:value].nil?

              fields = {}
              fields[walk[:identifier]] = "#{walk[:value]}i"
              tags = {
                hostname: device.values[:hostname],
                interface: index[key],
                ip_address: device.values[:ip_address],
                zone: device.values[:zone],
                env: device.values[:environment],
                dc: device.values[:datacenter],
                influxdb_node_group: 'snmp'
              }

              line = Telemetry::Metrics::Parser.to_line_protocol(
                measurement: row.values[:measurement],
                fields: fields,
                tags: tags,
                timestamp: timestamp
              )

              @lines.push line
            end
          rescue StandardError => e
            Telemetry::Logger.error "#{e.class}: #{hostname}, #{e.message}"
          end

          @lines
        end
      end
    end
  end
end
