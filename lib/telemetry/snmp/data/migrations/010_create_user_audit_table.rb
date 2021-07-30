Sequel.migration do
  change do
    create_table(:user_audit_logs) do
      primary_key :id
      TrueClass :success, null: false, default: 1
      foreign_key :user_id, :users, null: false
      foreign_key :device_id, :devices, null: true
      foreign_key :device_cred_id, :device_creds, null: true
      foreign_key :oid_walk_id, :oid_walks, null: true
      foreign_key :oid_id, :oids, null: true

      String :entry, text: true

      DateTime :created
      DateTime :updated
    end
  end
end
