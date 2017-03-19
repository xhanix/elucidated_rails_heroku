# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170319030038) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authusers", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.index ["email"], name: "index_authusers_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_authusers_on_reset_password_token", unique: true, using: :btree
  end

  create_table "invoice_payments", force: :cascade do |t|
    t.string   "stripe_id"
    t.integer  "amount"
    t.integer  "fee_amount"
    t.integer  "user_id"
    t.integer  "subscription_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["subscription_id"], name: "index_invoice_payments_on_subscription_id", using: :btree
    t.index ["user_id"], name: "index_invoice_payments_on_user_id", using: :btree
  end

  create_table "plans", force: :cascade do |t|
    t.string   "stripe_id"
    t.string   "name"
    t.text     "description"
    t.integer  "amount"
    t.string   "interval"
    t.boolean  "published"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "product_id"
    t.integer  "trial_period_days"
    t.index ["product_id"], name: "index_plans_on_product_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.string   "permalink"
    t.text     "description"
    t.integer  "price"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
  end

  create_table "sales", force: :cascade do |t|
    t.string   "email"
    t.string   "guid"
    t.integer  "product_id"
    t.string   "stripe_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "state"
    t.string   "stripe_token"
    t.date     "card_expiration"
    t.text     "error"
    t.integer  "fee_amount"
    t.integer  "amount"
    t.index ["product_id"], name: "index_sales_on_product_id", using: :btree
  end

  create_table "stripe_webhooks", force: :cascade do |t|
    t.string   "stripe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "plan_id"
    t.string   "stripe_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "guid"
    t.string   "state"
    t.text     "error"
    t.string   "braintree_id"
    t.string   "status"
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id", using: :btree
    t.index ["user_id"], name: "index_subscriptions_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "stripe_customer_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "email"
    t.string   "guid"
    t.string   "encrypted_description"
    t.string   "encrypted_description_iv"
    t.string   "fullname"
    t.string   "braintree_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.integer  "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.text     "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  add_foreign_key "invoice_payments", "subscriptions"
  add_foreign_key "invoice_payments", "users"
  add_foreign_key "plans", "products"
  add_foreign_key "sales", "products"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "subscriptions", "users"
end
