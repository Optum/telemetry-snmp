Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :username, required: true, null: false, unique: true
      String :email, required: true, null: false, unique: true

      TrueClass :active, null: false, default: 1
      TrueClass :admin, null: false, default: 0

      DateTime :created
      DateTime :updated

      unique :username
      unique :email
      index :active
      index :admin
    end
  end
end
