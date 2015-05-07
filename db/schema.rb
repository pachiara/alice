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

ActiveRecord::Schema.define(version: 20150429140818) do

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",        limit: 15
    t.string   "description", limit: 50
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree

  create_table "components", force: :cascade do |t|
    t.string   "name",        limit: 50
    t.string   "version",     limit: 25
    t.string   "title",       limit: 50
    t.text     "description", limit: 65535
    t.integer  "license_id",  limit: 4
    t.integer  "use_id",      limit: 4
    t.date     "checked_at"
    t.boolean  "result",      limit: 1,     default: true
    t.text     "notes",       limit: 65535
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "purchased",   limit: 1,     default: false
    t.boolean  "own",         limit: 1,     default: false
    t.boolean  "leave_out",   limit: 1,     default: false
  end

  add_index "components", ["license_id"], name: "index_components_on_license_id", using: :btree
  add_index "components", ["name", "version"], name: "index_components_on_name_and_version", unique: true, using: :btree
  add_index "components", ["title"], name: "index_components_on_title", using: :btree
  add_index "components", ["use_id"], name: "index_components_on_use_id", using: :btree

  create_table "components_releases", id: false, force: :cascade do |t|
    t.integer "release_id",   limit: 4, null: false
    t.integer "component_id", limit: 4, null: false
  end

  add_index "components_releases", ["component_id", "release_id"], name: "index_components_releases_on_component_id_and_release_id", unique: true, using: :btree
  add_index "components_releases", ["release_id", "component_id"], name: "index_components_releases_on_release_id_and_component_id", unique: true, using: :btree

  create_table "detected_components", force: :cascade do |t|
    t.integer  "detection_id",    limit: 4
    t.string   "name",            limit: 255
    t.string   "version",         limit: 255
    t.string   "license_name",    limit: 255
    t.string   "license_version", limit: 255
    t.integer  "component_id",    limit: 4
    t.integer  "license_id",      limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.boolean  "own",             limit: 1,   default: false
  end

  add_index "detected_components", ["detection_id"], name: "index_detected_components_on_detection_id", using: :btree

  create_table "detections", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "xml_file_name",    limit: 255
    t.string   "xml_content_type", limit: 255
    t.integer  "xml_file_size",    limit: 4
    t.datetime "xml_updated_at"
    t.boolean  "acquired",         limit: 1,   default: false
    t.integer  "release_id",       limit: 4
  end

  create_table "license_types", force: :cascade do |t|
    t.string   "code",             limit: 2
    t.string   "description",      limit: 50
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "protection_level", limit: 4
  end

  add_index "license_types", ["code"], name: "index_license_types_on_code", unique: true, using: :btree

  create_table "licenses", force: :cascade do |t|
    t.string   "name",               limit: 15
    t.string   "description",        limit: 100
    t.string   "version",            limit: 5
    t.integer  "category_id",        limit: 4
    t.integer  "license_type_id",    limit: 4
    t.boolean  "flag_osi",           limit: 1,     default: true
    t.text     "text_license",       limit: 65535
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.text     "notes",              limit: 65535
    t.integer  "similar_license_id", limit: 4
  end

  add_index "licenses", ["category_id"], name: "index_licenses_on_category_id", using: :btree
  add_index "licenses", ["description"], name: "index_licenses_on_description", using: :btree
  add_index "licenses", ["license_type_id"], name: "index_licenses_on_type_id", using: :btree
  add_index "licenses", ["name", "version"], name: "index_licenses_on_name_and_version", unique: true, using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "name",        limit: 30
    t.string   "title",       limit: 100
    t.text     "description", limit: 65535
    t.integer  "use_id",      limit: 4
    t.text     "notes",       limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "products", ["name"], name: "index_products_on_name_and_version", unique: true, using: :btree
  add_index "products", ["title"], name: "index_products_on_title", using: :btree
  add_index "products", ["use_id"], name: "index_products_on_use_id", using: :btree

  create_table "releases", force: :cascade do |t|
    t.integer  "product_id",            limit: 4
    t.string   "version_name",          limit: 25
    t.decimal  "sequential_number",                   precision: 9, scale: 3
    t.integer  "license_id",            limit: 4
    t.boolean  "check_result",          limit: 1
    t.date     "checked_at"
    t.integer  "compatible_license_id", limit: 4
    t.text     "notes",                 limit: 65535
    t.string   "groupage",              limit: 25
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rule_entries", force: :cascade do |t|
    t.integer  "rule_id",    limit: 4
    t.integer  "license_id", limit: 4
    t.boolean  "plus",       limit: 1
    t.integer  "order_id",   limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "rule_entries", ["order_id"], name: "index_rule_entries_on_order_id", using: :btree

  create_table "rules", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "license_id", limit: 4
    t.boolean  "plus",       limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "rules", ["license_id"], name: "index_rules_on_license_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.boolean  "admin",                  limit: 1,   default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "uses", force: :cascade do |t|
    t.string   "name",        limit: 5
    t.string   "description", limit: 100
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "uses", ["name"], name: "index_uses_on_name", unique: true, using: :btree

end
