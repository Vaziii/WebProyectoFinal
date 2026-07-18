# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_07_18_231527) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_categories_on_lower_name", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "stock", default: 0, null: false
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["name"], name: "index_products_on_name"
    t.check_constraint "price > 0::numeric", name: "products_price_positive"
    t.check_constraint "stock >= 0", name: "products_stock_non_negative"
  end

  create_table "receipt_items", force: :cascade do |t|
    t.bigint "receipt_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 12, scale: 2, null: false
    t.decimal "subtotal", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_receipt_items_on_product_id"
    t.index ["receipt_id", "product_id"], name: "index_receipt_items_on_receipt_and_product", unique: true
    t.index ["receipt_id"], name: "index_receipt_items_on_receipt_id"
    t.check_constraint "quantity > 0", name: "receipt_items_quantity_positive"
    t.check_constraint "subtotal > 0::numeric", name: "receipt_items_subtotal_positive"
    t.check_constraint "unit_price > 0::numeric", name: "receipt_items_unit_price_positive"
  end

  create_table "receipts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "amount_of_items", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_receipts_on_user_id"
    t.check_constraint "amount_of_items > 0", name: "receipts_amount_of_items_positive"
    t.check_constraint "total >= 0::numeric", name: "receipts_total_non_negative"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", limit: 80, null: false
    t.string "last_name", limit: 80, null: false
    t.string "email", limit: 255, null: false
    t.string "password_digest", null: false
    t.string "address", limit: 255
    t.string "phone_number", limit: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
  end

  add_foreign_key "products", "categories"
  add_foreign_key "receipt_items", "products"
  add_foreign_key "receipt_items", "receipts"
  add_foreign_key "receipts", "users"
end
