Sequel.migration do
  change do
    alter_table(:oids) do
      add_column :active, Integer, limit: 1, null: false, default: 1, index: true
      add_column :measurement_name, String, null: false, default: 'snmp'
    end
  end
end
