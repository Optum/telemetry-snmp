require 'sinatra/extension'
require 'oj'
require 'multi_json'

module Telemetry
  module Snmp
    module Controller
      module Walks
        extend Sinatra::Extension
        # id, oid_index, oid_walk, active, measurement_name, created, updated

        get '' do
          results = {}
          Telemetry::Snmp::Data::Model::OIDWalks.all.each do |walk|
            results[walk.values[:id]] = walk.values
          end

          results
        end

        get '/:id' do
          result = Telemetry::Snmp::Data::Model::OIDWalks[params[:id]]
          return {} if result.nil?

          result.values
        end

        post '' do
          body = MultiJson.load(request.body.read, symbolize_keys: true)
          insert = {
            oid_index: body[:oid_index],
            oid_walk: body[:oid_walk],
            active: body[:active] || 1,
            measurement_name: body[:measurement_name] || 'snmp',
            created: Sequel::CURRENT_TIMESTAMP
          }

          if insert[:oid_index].nil? || insert[:oid_walk].nil?
            status 400
            { error: true, missing_oid_index: insert[:oid_index].nil?, missing_oid_walk: insert[:oid_walk].nil? }
          end

          { id: Telemetry::Snmp::Data::Model::OIDWalks.insert(**insert), error: false }
        end

        patch '/:id' do
          result = Telemetry::Snmp::Data::Model::OIDWalks[params[:id]]
          if result.nil?
            status 404
            return { error: true, message: "#{param[:id]} not found" }
          end

          update = {}
          fields = %i[oid_index oid_walk active measurement_name]
          body = MultiJson.load(request.body.read, symbolize_keys: true)
          fields.each do |field|
            next unless body.key? field

            update[field] = body[field]
          end

          if update.empty?
            status 400
            return { error: true, message: 'no valid fields to update' }
          end

          update[:updated] = Sequel::CURRENT_TIMESTAMP
          result.update(**update)
          { error: false, updated_field: update, id: params[:id] }
        end

        put '/:id' do
          status 405
          { error: true, message: 'puts not supported', id: params[:id] }
        end

        delete '/:id' do
          result = Telemetry::Snmp::Data::Model::OIDWalks[params[:id]]
          if result.nil?
            status 404
            return { error: true, message: "#{param[:id]} not found" }
          end

          { error: result.delete, id: params[:id] }
        end
      end
    end
  end
end
