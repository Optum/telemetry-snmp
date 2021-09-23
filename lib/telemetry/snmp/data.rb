require 'sequel'
require 'sequel/extensions/migration'
require 'sequel/plugins/serialization'

require 'telemetry/snmp/data/default_opts'
require 'oj'

module Telemetry
  module Snmp
    module Data
      extend Telemetry::Snmp::Data::DefaultOpts

      class << self
        def migration_path
          "#{__dir__}/data/migrations"
        end

        def migration
          @migration_version = Sequel::Migrator.run(connection, migration_path, use_transactions: true)
        end

        def migration_version
          @migration_version || migration
        end

        def migrations_up_to_date?
          Sequel::Migrator.check_current(connection, migration_path)
          true
        rescue Sequel::Migrator::NotCurrentError
          false
        end

        def load_models(*models_array)
          models_array = models if models_array.empty?
          models_array.each do |model|
            require "telemetry/snmp/data/models/#{model}.rb"
          end
        end

        def models
          %w[user device_cred device device_lock oid oid_group oid_oid_groups oid_walk user_audit_log]
        end

        def connection(**opts)
          @connection ||= Sequel.connect(**opts.merge(default_credentials))
        end

        def connected?
          connection.test_connection
        end

        def setup_oj_serializer
          Sequel::Plugins::Serialization.register_format(:oj_json,
                                                         ->(value) { Oj.dump(value) },
                                                         ->(value) { Oj.load(value.nil? ? 'null' : value) })
        end

        def start!
          raise 'failed to start db connection' unless connected?

          migration
          setup_oj_serializer

          load_models
        end
      end
    end
  end
end
