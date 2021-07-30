require 'sinatra/extension'

module Telemetry
  module Snmp
    module Controller
      module Users
        extend Sinatra::Extension
        get '' do
          users = {}
          Telemetry::Snmp::Data::Model::User.all.each do |user|
            users[user.values[:id]] = user.values
          end

          users
        end

        get '/:id' do
          user = Telemetry::Snmp::Data::Model::User[params[:id]]
          status 404 if user.nil?
          return { error: true, message: "#{params[:id]} not found" } if user.nil?

          user.values
        end

        post '' do
          body = MultiJson.load(request.body.read, symbolize_keys: true)
          insert = {
            username: body[:username],
            email: body[:email],
            active: body[:active] || 1,
            admin: body[:admin] || 0,
            created: Sequel::CURRENT_TIMESTAMP
          }

          unless insert.values.include? nil
            status 400
            { error: true, message: 'missing required fields' }
          end

          { id: Telemetry::Snmp::Data::Model::User.insert(**insert), username: body[:username] }
        end

        put '/:id' do
          user = Telemetry::Snmp::Data::Model::User[params[:id]]
          status 404 if user.nil?
          return { error: true, message: "#{params[:id]} not found" } if user.nil?

          status 405
          { error: true, message: 'puts not supported', id: params[:id] }
        end

        patch '/:id' do
          user = Telemetry::Snmp::Data::Model::User[params[:id]]
          status 404 if user.nil?
          return { error: true, message: "#{params[:id]} not found" } if user.nil?

          body = MultiJson.load(request.body.read, symbolize_keys: true)
          updates = {}
          fields = %i[username email active admin]
          fields.each { |field| updates[field] = body[field] if body.key? field }
          if updates.empty?
            status 400
            return { error: true, message: 'no valid fields to update' }
          end

          updates[:updated] = Sequel::CURRENT_TIMESTAMP
          user.update(**updates)
          { error: false, updated_fields: updates.keys, id: params[:id] }
        end

        delete '/:id' do
          user = Telemetry::Snmp::Data::Model::User[params[:id]]
          status 404 if user.nil?
          return { error: true, message: "#{params[:id]} not found" } if user.nil?

          { error: !user.delete, id: params[:id] }
        end
      end
    end
  end
end
