class CreateReceipts < ActiveRecord::Migration[7.1]
  def change
    create_table :receipts do |t|
      t.references :user,
                   null: false,
                   foreign_key: true,
                   index: true

      t.decimal :total,
                precision: 12,
                scale: 2,
                null: false,
                default: 0

      t.integer :amount_of_items,
                null: false,
                default: 0

      t.timestamps
    end

    add_check_constraint :receipts,
                         "total >= 0",
                         name: "receipts_total_non_negative"

    add_check_constraint :receipts,
                         "amount_of_items > 0",
                         name: "receipts_amount_of_items_positive"
  end
end