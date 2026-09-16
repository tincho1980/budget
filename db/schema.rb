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

ActiveRecord::Schema[8.1].define(version: 2026_09_16_214526) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "budget_items", force: :cascade do |t|
    t.boolean "billable", default: true, null: false
    t.bigint "budget_id", null: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.decimal "estimated_hours", precision: 8, scale: 2, null: false
    t.integer "level", null: false
    t.string "module_name"
    t.integer "position"
    t.bigint "rate_id", null: false
    t.datetime "updated_at", null: false
    t.index ["budget_id"], name: "index_budget_items_on_budget_id"
    t.index ["rate_id"], name: "index_budget_items_on_rate_id"
  end

  create_table "budgets", force: :cascade do |t|
    t.datetime "approved_at"
    t.decimal "buffer_percentage", precision: 5, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.text "notes"
    t.bigint "project_id", null: false
    t.datetime "sent_at"
    t.integer "status", default: 0, null: false
    t.decimal "total", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.integer "version", default: 1, null: false
    t.index ["project_id", "version"], name: "index_budgets_on_project_id_and_version", unique: true
    t.index ["project_id"], name: "index_budgets_on_project_id"
  end

  create_table "clients", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "business_name", null: false
    t.string "contact_name"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "phone"
    t.string "tax_id"
    t.datetime "updated_at", null: false
    t.index ["tax_id"], name: "index_clients_on_tax_id", unique: true
  end

  create_table "maintenance_charges", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.date "due_on", null: false
    t.bigint "maintenance_contract_id", null: false
    t.string "period", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["maintenance_contract_id", "period"], name: "idx_on_maintenance_contract_id_period_f64ee3eb25", unique: true
    t.index ["maintenance_contract_id"], name: "index_maintenance_charges_on_maintenance_contract_id"
  end

  create_table "maintenance_contracts", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.integer "due_day", null: false
    t.date "ends_on"
    t.decimal "monthly_amount", precision: 12, scale: 2, null: false
    t.bigint "project_id"
    t.date "starts_on", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_maintenance_contracts_on_client_id"
    t.index ["project_id"], name: "index_maintenance_contracts_on_project_id"
  end

  create_table "payment_applications", force: :cascade do |t|
    t.decimal "applied_amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.bigint "maintenance_charge_id", null: false
    t.bigint "payment_id", null: false
    t.datetime "updated_at", null: false
    t.index ["maintenance_charge_id"], name: "index_payment_applications_on_maintenance_charge_id"
    t.index ["payment_id", "maintenance_charge_id"], name: "idx_on_payment_id_maintenance_charge_id_f0d09b76c1", unique: true
    t.index ["payment_id"], name: "index_payment_applications_on_payment_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.text "notes"
    t.date "paid_on", null: false
    t.integer "payment_method", null: false
    t.bigint "registered_by_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_payments_on_client_id"
    t.index ["registered_by_id"], name: "index_payments_on_registered_by_id"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.date "closed_on"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.date "started_on"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_projects_on_client_id"
  end

  create_table "rates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "hourly_value", precision: 12, scale: 2, null: false
    t.integer "level", null: false
    t.datetime "updated_at", null: false
    t.date "valid_from", null: false
    t.index ["level", "valid_from"], name: "index_rates_on_level_and_valid_from", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "time_entries", force: :cascade do |t|
    t.bigint "budget_item_id", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.decimal "hours", precision: 8, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.date "worked_on", null: false
    t.index ["budget_item_id"], name: "index_time_entries_on_budget_item_id"
    t.index ["user_id"], name: "index_time_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "api_token"
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.integer "level"
    t.string "name", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 50, null: false
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["client_id"], name: "index_users_on_client_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "budget_items", "budgets"
  add_foreign_key "budget_items", "rates"
  add_foreign_key "budgets", "projects"
  add_foreign_key "maintenance_charges", "maintenance_contracts"
  add_foreign_key "maintenance_contracts", "clients"
  add_foreign_key "maintenance_contracts", "projects"
  add_foreign_key "payment_applications", "maintenance_charges"
  add_foreign_key "payment_applications", "payments"
  add_foreign_key "payments", "clients"
  add_foreign_key "payments", "users", column: "registered_by_id"
  add_foreign_key "projects", "clients"
  add_foreign_key "sessions", "users"
  add_foreign_key "time_entries", "budget_items"
  add_foreign_key "time_entries", "users"
  add_foreign_key "users", "clients"
end
