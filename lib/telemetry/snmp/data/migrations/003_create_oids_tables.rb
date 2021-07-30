Sequel.migration do
  change do
    create_table(:oids) do
      primary_key :id
      String :oid, null: false, unique: true
      String :name, null: false
      String :description, null: true

      DateTime :created
      DateTime :updated

      index :oid
      index :name
    end
  end
end
