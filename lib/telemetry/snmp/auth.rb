require 'net/ldap'
require 'telemetry/snmp/auth/defaults'

module Telemetry
  module Snmp
    class Auth
      include Telemetry::Snmp::AuthDefaults

      def initialize(username:, **opts)
        @username = username
        @details = {}
        @opts = opts
      end

      def process_result(result)
        unless result.is_a? Net::LDAP::Entry
          @success = false
          return
        end
        @details[:username] = result.sAMAccountName.first
        @details[:email] = result.mail.first
        @details[:first] = result.givenName.first
        @details[:last] = result.sn.first
        @success = true
      end

      def search_user(ldap, username)
        user_filter = Net::LDAP::Filter.eq('sAMAccountName', username)

        ldap.search(base: treebase, filter: user_filter, attrs: attrs, return_result: false) do |entry|
          @details[:group_access] = entry.memberof.include?("CN=#{admin_group}, #{treebase}")
          return entry
        end
      end

      def auth_with_service(password)
        options = defaults
        options[:auth] = defaults_auth
        result = provider.new(options).bind_as(base: defaults[:base], attributes: attrs, filter: filter, password: password) # rubocop:disable Layout/LineLength
        process_result(result.first)
      end

      def auth_without_service(password)
        options = { host: defaults[:host], port: defaults[:port] }
        options[:auth] = { password: password, username: @username, method: :simple }
        ldap = provider.new(options)
        @success = ldap.bind
        return unless @success

        process_result(search_user(ldap, @username))
      end
    end
  end
end
