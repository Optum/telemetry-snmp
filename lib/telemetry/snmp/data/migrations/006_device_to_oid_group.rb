Sequel.migration do
  change do
    create_table(:oid_groups_device) do
      primary_key :id
      foreign_key :device_id, :devices, null: false
      foreign_key :oid_group_id, :oid_groups, null: false

      DateTime :created
      DateTime :updated

      index :device_id
      index :oid_group_id
    end
  end
end
