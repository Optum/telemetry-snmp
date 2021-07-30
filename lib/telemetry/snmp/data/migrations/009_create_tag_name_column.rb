Sequel.migration do
  change do
    alter_table(:oid_walks) do
      add_column :tag_name, String
    end
  end
end
