require 'sinatra/extension'

module Telemetry
  module Snmp
    module Controller
      module OIDs
        extend Sinatra::Extension

        get '' do
          oids = {}

          Telemetry::Snmp::Data::MOdel::OID.all.each do |oid|
            oids[oid.values[:id]] = oid.values
          end

          oids
        end

        get '/:id' do
          oid = Telemetry::Snmp::Data::Model::OID[params[:id]]
          status 404 if oid.nil?
          return { error: true, message: "#{params[:id]} not found" } if oid.nil?

          oid.values
        end

        post '' do
          body = MultiJson.load(request.body.read, symbolize_keys: true)
          status 400 if body[:oid].nil?
          { error: true, message: 'oid is a required field' } if body[:oid].nil?

          insert = {
            oid: body[:oid],
            name: body[:name],
            description: body[:description],
            created: Sequel::CURRENT_TIMESTAMP
          }

          { id: Telemetry::Snmp::Data::Model::OID.insert(**insert), oid: body[:oid] }
        end

        put '/:id' do
          oid = Telemetry::Snmp::Data::Model::OID[params[:id]]
          status 404 if oid.nil?
          return { error: true, message: "#{params[:id]} not found" } if oid.nil?

          status 405
          { error: true, message: 'puts not supported', id: params[:id] }
        end

        patch '/:id' do
          oid = Telemetry::Snmp::Data::Model::OID[params[:id]]
          status 404 if oid.nil?
          return { error: true, message: "#{params[:id]} not found" } if oid.nil?

          body = MultiJson.load(request.body.read, symbolize_keys: true)
          updates = {}
          fields = %i[oid name description]
          fields.each { |field| updates[field] = body[field] if body.key? field }
          if updates.empty?
            status 400
            return { error: true, message: 'no valid fields to update' }
          end

          updates[:updated] = Sequel::CURRENT_TIMESTAMP
          oid.update(**updates)
          { error: false, updated_fields: updates.keys, id: params[:id] }
        end

        delete '/:id' do
          oid = Telemetry::Snmp::Data::Model::OID[params[:id]]
          status 404 if oid.nil?
          return { error: true, message: "#{params[:id]} not found" } if oid.nil?

          { error: !oid.delete, id: params[:id] }
        end
      end
    end
  end
end
