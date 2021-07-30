require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/multi_route'
require 'sinatra/respond_with'
require 'sinatra/custom_logger'
require 'sinatra/namespace'
require 'oj'

require 'telemetry/snmp/controllers/device_creds'
require 'telemetry/snmp/controllers/devices'
require 'telemetry/snmp/controllers/oid_groups'
require 'telemetry/snmp/controllers/oids'
require 'telemetry/snmp/controllers/users'
require 'telemetry/snmp/controllers/walks'

module Telemetry
  module Snmp
    class API < Sinatra::Base
      register Sinatra::JSON
      register Sinatra::Namespace
      register Sinatra::RespondWith

      error do
        content_type :json
        status 500

        { result: 'error', message: env['sinatra.error'].message }.to_json
      end

      before do
        headers 'Access-Control-Allow-Origin' => '*',
                'Access-Control-Allow-Methods' => %w[OPTIONS GET POST]
      end

      after do
        content_type :json
        response.body = Oj.dump(response.body, mode: :compat) unless response.body.is_a? String
      end

      get '/version' do
        {
          version: Telemetry::Snmp::VERSION,
          migration_version: Telemetry::Snmp::Data.migration_version
        }
      end

      namespace('/users') { register Telemetry::Snmp::Controller::Users }
      namespace('/devices/creds') { register Telemetry::Snmp::Controller::DeviceCreds }
      namespace('/devices') { register Telemetry::Snmp::Controller::Devices }
      namespace('/oid_groups') { register Telemetry::Snmp::Controller::OIDGroups }
      namespace('/oid') { register Telemetry::Snmp::Controller::OIDs }
      namespace('/walks') { register Telemetry::Snmp::Controller::Walks }
    end
  end
end
