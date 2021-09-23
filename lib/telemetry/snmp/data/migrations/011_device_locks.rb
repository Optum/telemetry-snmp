Sequel.migration do
  change do
    create_table(:device_locks) do
      primary_key :id
      String :worker_name, null: false
      foreign_key :device_id, :devices, null: false, unique: true

      DateTime :created
      DateTime :updated
      DateTime :expires

      index :device_id
      index :worker_name
      index :created
      index :updated
      index :expires
    end
  end
end
