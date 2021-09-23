module Telemetry
  module Snmp
    module Data
      module DefaultOpts
        def default_credentials
          {
            adapter: adapter,
            user: username,
            password: password,
            database: database,
            host: host,
            port: port,
            max_connections: max_connections,
            pool_timeout: pool_timeout,
            preconnect: preconnect,
            test: true
          }
        end
        module_function :default_credentials

        def adapter
          ENV["#{env_key}_adapter"] == 'postgres' ? 'postgres' : 'mysql2'
        end
        module_function :adapter

        def username
          ENV["#{env_key}_username"] || 'root'
        end
        module_function :username

        def password
          ENV["#{env_key}_password"] || nil
        end
        module_function :password

        def database
          ENV["#{env_key}_database"] || 'telemetry_snmp'
        end
        module_function :database

        def host
          ENV["#{env_key}_host"] || '127.0.0.1'
        end
        module_function :host

        def port
          ENV.key?("#{env_key}_port") ? ENV["#{env_key}_port"].to_i : 3306
        end
        module_function :port

        def max_connections
          ENV.key?("#{env_key}_max_connections") ? ENV["#{env_key}_max_connections"].to_i : 16
        end
        module_function :max_connections

        def pool_timeout
          ENV.key?("#{env_key}_pool_timeout") ? ENV["#{env_key}_pool_timeout"].to_i : 2
        end
        module_function :pool_timeout

        def preconnect
          ENV["#{env_key}_preconnect"] || 'concurrently'
        end
        module_function :preconnect

        def env_key
          'telemetry_snmp_data'
        end
        module_function :env_key
      end
    end
  end
end
