Sequel.migration do
  change do
    alter_table(:oids) do
      add_column :brand, String
      add_column :type, String
      add_column :role, String
    end
  end
end
