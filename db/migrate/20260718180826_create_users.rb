class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :first_name, null: false, limit: 80
      t.string :last_name, null: false, limit: 80
      t.string :email, null: false, limit: 255
      t.string :password_digest, null: false
      t.string :address, limit: 255
      t.string :phone_number, limit: 20

      t.timestamps
    end

    add_index :users,
              "LOWER(email)",
              unique: true,
              name: "index_users_on_lower_email"
  end
end