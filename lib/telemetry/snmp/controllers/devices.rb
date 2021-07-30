require 'sinatra/extension'

module Telemetry
  module Snmp
    module Controller
      module Devices
        extend Sinatra::Extension

        get '' do
          devices = {}
          Telemetry::Snmp::Data::Model::Device.all.each do |device|
            devices[device.values[:id]] = device.values
          end

          devices
        end

        get '/:id' do
          device = Telemetry::Snmp::Data::Model::Device[params[:id]]
          status 404 if device.nil?
          { error: true, message: "#{params[:id]} not found" } if device.nil?

          device.values
        end

        post '' do
          body = MultiJson.load(request.body.read, symbolize_keys: true)

          if body[:hostname].nil?
            status 400
            { error: true, message: 'hostname cannot be null for new record' }
          end

          {
            id: Telemetry::Snmp::Data::Model::User.insert(
              hostname: body[:hostname],
              ip_address: body[:ip_address],
              active: body[:active] || 1,
              port: body[:port] || 161,
              snmp_version: body[:snmp_version] || 3,
              device_cred_id: body[:device_cred_id],
              frequency: body[:frequency] || 60,
              environment: body[:environment] || 'production',
              datacenter: body[:datacenter],
              zone: body[:zone],
              created: Sequel::CURRENT_TIMESTAMP
            ),
            hostname: body[:hostname]
          }
        end

        put '/:id' do
          device = Telemetry::Snmp::Data::Model::Device[params[:id]]
          status 404 if device.nil?
          { error: true, message: "#{params[:id]} not found" } if device.nil?

          status 405
          { error: true, message: 'puts not supported', id: params[:id] }
        end

        patch '/:id' do
          # id, hostname, ip_address, active, port, snmp_version, device_cred_id,
          # frequency, environment, datacenter, zone, last_polled, created, updated
          device = Telemetry::Snmp::Data::Model::Device[params[:id]]
          status 404 if device.nil?
          { error: true, message: "#{params[:id]} not found" } if device.nil?

          body = MultiJson.load(request.body.read, symbolize_keys: true)
          updates = {}
          fields = %i[hostname ip_address active port snmp_version device_cred_id frequency environment
                      datacenter zone]
          fields.each { |field| updates[field] = body[field] if body.key? field }

          if updates.empty?
            status 400
            return { error: true, message: 'no valid fields to update' }
          end

          updates[:updated] = Sequel::CURRENT_TIMESTAMP
          device.update(**updates)
          { error: false, updated_fields: updates.keys, id: params[:id] }
        end

        delete '/:id' do
          device = Telemetry::Snmp::Data::Model::Device[params[:id]]
          status 404 if device.nil?
          { error: true, message: "#{params[:id]} not found" } if device.nil?

          { error: !device.delete, id: params[:id] }
        end
      end
    end
  end
end
