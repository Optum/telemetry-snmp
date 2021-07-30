require 'sinatra/extension'

module Telemetry
  module Snmp
    module Controller
      module DeviceCreds
        extend Sinatra::Extension
        # id, port, username, auth_password, auth_protocol, priv_password, priv_protocol, security_level

        get '' do
          results = {}

          Telemetry::Snmp::Data::Model::DeviceCred.all.each do |creds|
            results[creds.values[:id]] = {
              id: creds.values[:id],
              port: creds.values[:port],
              username: creds.values[:username],
              auth_protocol: creds.values[:auth_protcol],
              priv_protocol: creds.values[:priv_protocol],
              security_level: creds.values[:security_level],
              created: creds.values[:created],
              updated: creds.values[:updated]
            }
          end

          results
        end

        get '/:id' do
          cred = Telemetry::Snmp::Data::Model::DeviceCred[params[:id]]
          if cred.nil?
            status 404
            return {}
          end

          results = cred.values.dup
          results.delete(:auth_password)
          results.delete(:priv_password)

          results
        end

        post '' do
          body = MultiJson.load(request.body.read, symbolize_keys: true)

          if params[:username].nil? || params[:auth_password].nil?
            status 400
            {
              error: true,
              username_missing: params[:username].nil?,
              auth_password_missing: params[:auth_password].nil?
            }
          end
          insert = {
            port: body[:port] || 161,
            username: body[:username],
            auth_password: body[:auth_password],
            auth_protocol: body[:auth_protocol] || 'sha',
            priv_password: body[:priv_password],
            priv_protocol: body[:priv_protocol] || 'aes',
            security_level: body[:security_level] || 'auth_priv',
            created: Sequel::CURRENT_TIMESTAMP
          }

          { id: Telemetry::Snmp::Data::Model::DeviceCred.insert(**insert), username: insert[:username] }
        end

        put '/:id' do
          status 405
          { error: true, message: 'puts not supported', id: params[:id] }
        end

        patch '/:id' do
          cred = Telemetry::Snmp::Data::Model::DeviceCred[params[:id]]
          if cred.nil?
            status 404
            return { error: true, id: params[:id], message: "cannot find #{params[:id]}" }
          end

          body = MultiJson.load(request.body.read, symbolize_keys: true)
          update = {}
          fields = %i[port username auth_password auth_protocol priv_password priv_protocol security_level]
          fields.each { |field| update[field] = body[field] if body.key? field }

          if update.empty?
            status 400
            return { error: true, message: 'no valid fields to update' }
          end

          update[:updated] = Sequel::CURRENT_TIMESTAMP
          cred.update(**update)
          { error: false, updated_field: update.keys, id: params[:id] }
        end

        delete '/:id' do
          cred = Telemetry::Snmp::Data::Model::DeviceCred[params[:id]]
          status 404 if cred.nil?
          return { error: true, message: "#{params[:id]} not found" } if cred.nil?

          { error: !result.delete, id: params[:id] }
        end
      end
    end
  end
end
