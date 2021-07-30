Sequel.migration do
  change do
    create_table(:oid_walks) do
      primary_key :id
      String :oid_index
      String :oid_walk
      TrueClass :active, null: false, default: 1
      String :measurement_name, null: false, default: 'snmp'

      DateTime :created
      DateTime :updated
    end
  end
end
