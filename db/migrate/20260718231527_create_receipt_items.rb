class CreateReceiptItems < ActiveRecord::Migration[7.1]
  def change
    create_table :receipt_items do |t|
      t.references :receipt,
                   null: false,
                   foreign_key: true,
                   index: true

      t.references :product,
                   null: false,
                   foreign_key: true,
                   index: true

      t.integer :quantity,
                null: false

      t.decimal :unit_price,
                precision: 12,
                scale: 2,
                null: false

      t.decimal :subtotal,
                precision: 12,
                scale: 2,
                null: false

      t.timestamps
    end

    add_index :receipt_items,
              %i[receipt_id product_id],
              unique: true,
              name: "index_receipt_items_on_receipt_and_product"

    add_check_constraint :receipt_items,
                         "quantity > 0",
                         name: "receipt_items_quantity_positive"

    add_check_constraint :receipt_items,
                         "unit_price > 0",
                         name: "receipt_items_unit_price_positive"

    add_check_constraint :receipt_items,
                         "subtotal > 0",
                         name: "receipt_items_subtotal_positive"
  end
end