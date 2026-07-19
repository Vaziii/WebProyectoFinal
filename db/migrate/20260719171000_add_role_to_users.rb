class AddRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :string, null: false, default: "usuario"
    add_index :users, :role
    add_check_constraint :users,
                         "role IN ('usuario', 'admin')",
                         name: "users_role_valid"
  end
end
