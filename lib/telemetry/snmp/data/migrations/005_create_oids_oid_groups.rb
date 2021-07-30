Sequel.migration do
  change do
    create_table(:oids_oid_groups) do
      primary_key :id
      String :name, null: false, unique: true
      TrueClass :active, null: false, default: 1
      foreign_key :oid_id, :oids, null: true
      foreign_key :oid_group_id, :oid_groups, null: true

      DateTime :created
      DateTime :updated

      index :name
      index :active
    end
  end
end
