require 'sinatra/extension'

module Telemetry
  module Snmp
    module Controller
      module OIDGroups
        extend Sinatra::Extension

        get '' do
          groups = {}
          Telemetry::Snmp::Data::Model::OIDGroup.all.each do |group|
            groups[group.values[:id]] = group.values
          end

          groups
        end

        get '/:id' do
          group = Telemetry::Snmp::Data::Model::OIDGroup[params[:id]]
          status 404 if group.nil?
          { error: true, message: "#{params[:id]} not found" } if group.nil?

          group.values
        end

        post '' do
          body = MultiJson.load(request.body.read, symbolize_keys: true)
          if body[:name].nil?
            status 400
            { error: true, message: 'name cannot be null for new record' }
          end

          {
            id: Telemetry::Snmp::Data::Model.OIDGroup.insert(
              name: body[:name],
              active: body[:active] || 1,
              created: Sequel::CURRENT_TIMESTAMP
            ),
            name: body[:name]
          }
        end

        put '/:id' do
          group = Telemetry::Snmp::Data::Model::OIDGroup[params[:id]]
          status 404 if group.nil?
          { error: true, message: "#{params[:id]} not found" } if group.nil?

          status 405
          { error: true, message: 'puts not supported', id: params[:id] }
        end

        patch '/:id' do
          group = Telemetry::Snmp::Data::Model::OIDGroup[params[:id]]
          status 404 if group.nil?
          { error: true, message: "#{params[:id]} not found" } if group.nil?

          status 405
          { error: true, message: 'patch not supported', id: params[:id] }
        end

        delete '/:id' do
          group = Telemetry::Snmp::Data::Model::OIDGroup[params[:id]]
          status 404 if group.nil?
          { error: true, message: "#{params[:id]} not found" } if group.nil?

          { success: !group.delete, id: params[:id] }
        end
      end
    end
  end
end
