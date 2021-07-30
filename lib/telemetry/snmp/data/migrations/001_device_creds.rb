Sequel.migration do
  change do
    create_table(:device_creds) do
      primary_key :id
      Integer :port, null: false, default: 161
      String :username, null: false, default: 'paf-tig'
      String :auth_password
      String :auth_protocol, null: false, default: 'sha'
      String :priv_password
      String :priv_protocol, null: false, default: 'aes'
      String :security_level, null: false, default: 'auth_priv'

      DateTime :created
      DateTime :updated

      index :username
    end
  end
end
