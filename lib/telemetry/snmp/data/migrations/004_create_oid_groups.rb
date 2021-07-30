Sequel.migration do
  change do
    create_table(:oid_groups) do
      primary_key :id
      String :name, null: false, unique: true
      TrueClass :active, null: false, default: 1

      DateTime :created
      DateTime :updated

      index :name
      index :active
    end
  end
end
