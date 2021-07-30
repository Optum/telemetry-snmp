module Telemetry
  module Snmp
    module AuthDefaults
      def opts
        @opts ||= {}
      end

      def attrs
        %w[mail cn sn objectclass givenName sAMAccountName MemberOf]
      end

      def treebase
        opts[:treebase] || ENV['treebase'] || 'CN=Users,DC=com'
      end

      def ldap_host
        opts[:ldap_host] || ENV['ldap_host'] || 'localhost'
      end

      def ldap_port
        opts[:ldap_port] || ENV['ldap_host'] || '389'
      end

      def provider
        Net::LDAP
      end

      def filter(username = @username)
        "(sAMAccountName=#{username})"
      end

      def admin_group
        opts[:admin_group] || ENV['ldap_admin_group']
      end

      def users_group
        opts[:users_group] || ENV['ldap_users_group']
      end
    end
  end
end
