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

ActiveRecord::Schema[7.2].define(version: 2026_04_06_144302) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "alerts", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "category"
    t.string "status"
    t.text "content"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_alerts_on_company_id"
  end

  create_table "branch_alerts", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.string "category"
    t.string "status"
    t.text "content"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_branch_alerts_on_branch_id"
  end

  create_table "branch_settings", force: :cascade do |t|
    t.integer "day"
    t.bigint "branch_id", null: false
    t.float "conversion"
    t.float "discount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "conversion_agent", default: 0.0, null: false
    t.index ["branch_id"], name: "index_branch_settings_on_branch_id"
  end

  create_table "branch_users", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.bigint "user_id", null: false
    t.boolean "active"
    t.boolean "manager_role", default: false
    t.boolean "basic_role", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "intermediate_role", default: false
    t.index ["branch_id"], name: "index_branch_users_on_branch_id"
    t.index ["user_id"], name: "index_branch_users_on_user_id"
  end

  create_table "branches", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name"
    t.string "address"
    t.bigint "city_id", null: false
    t.string "geolocation_link"
    t.boolean "main", default: false
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "days_sleep"
    t.integer "alert_days"
    t.decimal "alert_qty_movements"
    t.decimal "alert_amount"
    t.string "email"
    t.string "token"
    t.string "email_background_color"
    t.boolean "admits_exchange", default: false
    t.boolean "admits_product_exchange", default: false
    t.string "email_text_color"
    t.index ["city_id"], name: "index_branches_on_city_id"
    t.index ["company_id"], name: "index_branches_on_company_id"
  end

  create_table "catalog_products", force: :cascade do |t|
    t.bigint "catalog_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catalog_id"], name: "index_catalog_products_on_catalog_id"
    t.index ["product_id"], name: "index_catalog_products_on_product_id"
  end

  create_table "catalogs", force: :cascade do |t|
    t.string "name"
    t.bigint "group_id", null: false
    t.bigint "company_id"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "text_color", default: "#FFFFFF"
    t.string "background_color", default: "#0dcaf0"
    t.string "font_family"
    t.index ["company_id"], name: "index_catalogs_on_company_id"
    t.index ["group_id"], name: "index_catalogs_on_group_id"
  end

  create_table "cities", force: :cascade do |t|
    t.bigint "state_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.boolean "active", default: false
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.integer "days_sleep"
    t.integer "alert_days"
    t.decimal "alert_qty_movements"
    t.decimal "alert_amount"
    t.string "email"
    t.datetime "last_update_customers_job"
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "company_groups", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_groups_on_company_id"
    t.index ["group_id"], name: "index_company_groups_on_group_id"
  end

  create_table "company_settings", force: :cascade do |t|
    t.integer "day"
    t.bigint "company_id", null: false
    t.float "conversion"
    t.float "discount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_settings_on_company_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.string "category", default: "CLIENTE", null: false
    t.index ["company_id"], name: "index_customers_on_company_id"
    t.index ["person_id"], name: "index_customers_on_person_id"
  end

  create_table "group_users", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id", "group_id"], name: "index_group_users_on_user_id_and_group_id", unique: true
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "account_type"
  end

  create_table "movements", force: :cascade do |t|
    t.bigint "customer_id"
    t.bigint "branch_id"
    t.string "movement_type"
    t.decimal "amount"
    t.bigint "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "annulled", default: false
    t.bigint "movement_related_id"
    t.decimal "amount_discounted"
    t.float "conversion"
    t.float "discount"
    t.decimal "total_import"
    t.bigint "group_id"
    t.bigint "person_id"
    t.text "description"
    t.bigint "user_id"
    t.datetime "mail_delivered_at"
    t.index ["branch_id"], name: "index_movements_on_branch_id"
    t.index ["customer_id"], name: "index_movements_on_customer_id"
    t.index ["group_id"], name: "index_movements_on_group_id"
    t.index ["movement_related_id"], name: "index_movements_on_movement_related_id"
    t.index ["person_id"], name: "index_movements_on_person_id"
    t.index ["user_id"], name: "index_movements_on_user_id"
  end

  create_table "people", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "document_type"
    t.string "document_number"
    t.date "birth_date"
    t.string "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.integer "old_id"
    t.string "card_number"
    t.datetime "old_created_at"
  end

  create_table "person_addresses", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "address"
    t.string "geolocation_link"
    t.float "latitude"
    t.float "longitude"
    t.bigint "postal_code"
    t.bigint "city_id", null: false
    t.boolean "main"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_person_addresses_on_city_id"
    t.index ["person_id"], name: "index_person_addresses_on_person_id"
  end

  create_table "person_emails", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "email"
    t.boolean "active"
    t.boolean "main"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "validated_at"
    t.integer "email_validation_times_sended"
    t.integer "emails_sended", default: 0
    t.index ["person_id"], name: "index_person_emails_on_person_id"
  end

  create_table "person_phones", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.string "country_code"
    t.string "area_code"
    t.string "phone_number"
    t.string "phone_type"
    t.boolean "main"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id"], name: "index_person_phones_on_person_id"
  end

  create_table "person_relationships", force: :cascade do |t|
    t.bigint "person_id", null: false
    t.bigint "relationship_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "person_relation_id"
    t.index ["person_id"], name: "index_person_relationships_on_person_id"
    t.index ["person_relation_id"], name: "index_person_relationships_on_person_relation_id"
    t.index ["relationship_id"], name: "index_person_relationships_on_relationship_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "price"
    t.string "product_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "points"
    t.boolean "active", default: false
  end

  create_table "relationships", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "states", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_states_on_country_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "company_owner_role", default: false
    t.boolean "admin_role", default: false
    t.boolean "group_owner_role", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alerts", "companies"
  add_foreign_key "branch_alerts", "branches"
  add_foreign_key "branch_settings", "branches"
  add_foreign_key "branch_users", "branches"
  add_foreign_key "branch_users", "users"
  add_foreign_key "branches", "cities"
  add_foreign_key "branches", "companies"
  add_foreign_key "catalog_products", "catalogs"
  add_foreign_key "catalog_products", "products"
  add_foreign_key "catalogs", "companies"
  add_foreign_key "catalogs", "groups"
  add_foreign_key "cities", "states"
  add_foreign_key "companies", "users"
  add_foreign_key "company_groups", "companies"
  add_foreign_key "company_groups", "groups"
  add_foreign_key "company_settings", "companies"
  add_foreign_key "customers", "companies"
  add_foreign_key "customers", "people"
  add_foreign_key "group_users", "groups"
  add_foreign_key "group_users", "users"
  add_foreign_key "movements", "branches"
  add_foreign_key "movements", "customers"
  add_foreign_key "movements", "groups"
  add_foreign_key "movements", "movements", column: "movement_related_id"
  add_foreign_key "movements", "people"
  add_foreign_key "movements", "users"
  add_foreign_key "person_addresses", "cities"
  add_foreign_key "person_addresses", "people"
  add_foreign_key "person_emails", "people"
  add_foreign_key "person_phones", "people"
  add_foreign_key "person_relationships", "people"
  add_foreign_key "person_relationships", "people", column: "person_relation_id"
  add_foreign_key "person_relationships", "relationships"
  add_foreign_key "states", "countries"
end
