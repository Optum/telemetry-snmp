Sequel.migration do
  change do
    create_table(:devices) do
      primary_key :id
      String :hostname, null: false, unique: true
      String :ip_address, null: false, unique: true
      TrueClass :active, null: false, default: 1
      Integer :port, null: false, default: 161
      Integer :snmp_version, null: false, default: 3
      foreign_key :device_cred_id, :device_creds, null: true
      Integer :frequency, null: false, default: 60

      String :environment
      String :datacenter
      String :zone

      DateTime :last_polled
      DateTime :created
      DateTime :updated

      index :hostname, unique: true
      index :ip_address, unique: true
      index :active
      index :last_polled
      index :environment
      index :datacenter
      index :zone
      index :snmp_version
    end
  end
end
