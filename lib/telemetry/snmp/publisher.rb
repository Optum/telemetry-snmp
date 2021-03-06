require 'telemetry/amqp'

module Telemetry
  module Snmp
    module Publisher
      class << self
        def start!(**opts)
          @opts = opts
          @opts[:amqp] = {} if opts[:amqp].nil?

          @session = nil
          @channel = nil
          @exchange = nil
          session
          channel
          true
        end

        def opts
          @opts ||= { amqp: {} }
        end

        def username
          if ENV.key? 'telemetry_snmp_amqp_username'
            ENV['telemetry_snmp_amqp_username']
          elsif opts[:amqp].key? :username
            opts[:amqp][:username]
          else
            'guest'
          end
        end

        def password
          ENV['telemetry_snmp_amqp_password'] || opts[:amqp][:password] || 'guest'
        end

        def vhost
          ENV['telemetry_snmp_amqp_vhost'] || opts[:amqp][:vhost] || 'telemetry'
        end

        def port
          if ENV.key? 'telemetry_snmp_amqp_port'
            ENV['telemetry_snmp_amqp_port'].to_i
          elsif opts[:amqp].key? :port
            opts[:amqp][:port]
          elsif use_ssl?
            5671
          else
            5672
          end
        end

        def use_ssl?
          if ENV.key? 'telemetry_snmp_amqp_use_ssl'
            %w[1 true].include? ENV['telemetry_snmp_amqp_use_ssl']
          elsif opts[:amqp].key?(:use_ssl)
            opts[:amqp][:use_ssl]
          else
            false
          end
        end

        def nodes
          if ENV.key?('telemetry_snmp_amqp_nodes')
            ENV['telemetry_snmp_amqp_nodes'].split(',')
          elsif opts[:amqp].key?(:nodes)
            opts[:amqp][:nodes]
          else
            ['localhost']
          end
        end

        def exchange_name
          ENV['telemetry_snmp_amqp_exchange_name'] || opts[:amqp][:exchange_name] || 'telemetry.snmp'
        end

        def session
          @session ||= Telemetry::AMQP::Base.new(
            auto_start: true,
            vhost: vhost,
            application: 'Telemetry::Snmp',
            app_version: Telemetry::Snmp::VERSION,
            username: username,
            password: password,
            port: port,
            nodes: nodes
          )
        end

        def push_lines(lines)
          line_exchange.publish(lines.join("\n"), **publish_opts, routing_key: 'snmp')
        end

        def channel
          if !@channel_thread.nil? && !@channel_thread.value.nil? && @channel_thread.value.open?
            return @channel_thread.value
          end

          @channel_thread = Concurrent::ThreadLocalVar.new(nil) if @channel_thread.nil?
          @channel_thread.value = session.create_channel
          @channel_thread.value
        end

        def line_exchange
          @exchange ||= channel.topic(
            exchange_name,
            durable: true,
            auto_delete: false,
            internal: false,
            passive: false
          )
        rescue Bunny::PreconditionFailed
          @exchange ||= channel.topic(exchange_name, passive: true)
        end

        def publish_opts
          {
            routing_key: 'snmp',
            persistent: true,
            mandatory: false,
            timestamp: Time.now.to_i,
            type: 'metric',
            content_type: 'application/json',
            content_encoding: 'identity'
          }
        end
      end
    end
  end
end
