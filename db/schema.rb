# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140417152903) do

  create_table "admins", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "categories", force: true do |t|
    t.string   "name",        limit: 15
    t.string   "description", limit: 50
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "components", force: true do |t|
    t.string   "name",        limit: 50
    t.string   "version",     limit: 25
    t.string   "title",       limit: 50
    t.text     "description"
    t.integer  "license_id"
    t.integer  "use_id"
    t.date     "checked_at"
    t.boolean  "result",                 default: true
    t.text     "notes"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "purchased",              default: false
    t.boolean  "own",                    default: false
    t.boolean  "leave_out",              default: false
  end

  add_index "components", ["license_id"], name: "index_components_on_license_id", using: :btree
  add_index "components", ["name", "version"], name: "index_components_on_name_and_version", unique: true, using: :btree
  add_index "components", ["title"], name: "index_components_on_title", using: :btree
  add_index "components", ["use_id"], name: "index_components_on_use_id", using: :btree

  create_table "components_products", id: false, force: true do |t|
    t.integer "product_id",   null: false
    t.integer "component_id", null: false
  end

  add_index "components_products", ["component_id", "product_id"], name: "index_components_products_on_component_id_and_product_id", unique: true, using: :btree
  add_index "components_products", ["product_id", "component_id"], name: "index_components_products_on_product_id_and_component_id", unique: true, using: :btree

  create_table "detected_components", force: true do |t|
    t.integer  "detection_id"
    t.string   "name"
    t.string   "version"
    t.string   "license_name"
    t.string   "license_version"
    t.integer  "component_id"
    t.integer  "license_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "own",             default: false
  end

  add_index "detected_components", ["detection_id"], name: "index_detected_components_on_detection_id", using: :btree

  create_table "detections", force: true do |t|
    t.string   "name"
    t.integer  "product_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "xml_file_name"
    t.string   "xml_content_type"
    t.integer  "xml_file_size"
    t.datetime "xml_updated_at"
    t.boolean  "acquired",         default: false
  end

  create_table "license_types", force: true do |t|
    t.string   "code",             limit: 2
    t.string   "description",      limit: 50
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "protection_level"
  end

  add_index "license_types", ["code"], name: "index_license_types_on_code", unique: true, using: :btree

  create_table "licenses", force: true do |t|
    t.string   "name",               limit: 15
    t.string   "description",        limit: 100
    t.string   "version",            limit: 5
    t.integer  "category_id"
    t.integer  "license_type_id"
    t.boolean  "flag_osi",                       default: true
    t.text     "text_license"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.text     "notes"
    t.integer  "similar_license_id"
  end

  add_index "licenses", ["category_id"], name: "index_licenses_on_category_id", using: :btree
  add_index "licenses", ["description"], name: "index_licenses_on_description", using: :btree
  add_index "licenses", ["license_type_id"], name: "index_licenses_on_type_id", using: :btree
  add_index "licenses", ["name", "version"], name: "index_licenses_on_name_and_version", unique: true, using: :btree

  create_table "products", force: true do |t|
    t.string   "name",                  limit: 30
    t.string   "version",               limit: 25
    t.string   "title",                 limit: 100
    t.text     "description"
    t.integer  "license_id"
    t.integer  "use_id"
    t.date     "checked_at"
    t.boolean  "result"
    t.text     "notes"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "compatible_license_id"
    t.string   "groupage",              limit: 25
  end

  add_index "products", ["license_id"], name: "index_products_on_license_id", using: :btree
  add_index "products", ["name", "version"], name: "index_products_on_name_and_version", unique: true, using: :btree
  add_index "products", ["title"], name: "index_products_on_title", using: :btree
  add_index "products", ["use_id"], name: "index_products_on_use_id", using: :btree

  create_table "rule_entries", force: true do |t|
    t.integer  "rule_id"
    t.integer  "license_id"
    t.boolean  "plus"
    t.integer  "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "rule_entries", ["order_id"], name: "index_rule_entries_on_order_id", using: :btree

  create_table "rules", force: true do |t|
    t.string   "name"
    t.integer  "license_id"
    t.boolean  "plus"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "rules", ["license_id"], name: "index_rules_on_license_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "uses", force: true do |t|
    t.string   "name",        limit: 5
    t.string   "description", limit: 100
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "uses", ["name"], name: "index_uses_on_name", unique: true, using: :btree

end
