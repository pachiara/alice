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

ActiveRecord::Schema.define(version: 2018_09_24_144054) do

  create_table "admins", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 15
    t.string "description", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "components", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 50
    t.string "version", limit: 25
    t.string "title", limit: 50
    t.text "description"
    t.integer "license_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "purchased", default: false
    t.boolean "own", default: false
    t.boolean "leave_out", default: false
    t.index ["license_id"], name: "index_components_on_license_id"
    t.index ["name", "version"], name: "index_components_on_name_and_version", unique: true
    t.index ["title"], name: "index_components_on_title"
  end

  create_table "components_releases", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "release_id", null: false
    t.integer "component_id", null: false
    t.index ["component_id", "release_id"], name: "index_components_releases_on_component_id_and_release_id", unique: true
    t.index ["release_id", "component_id"], name: "index_components_releases_on_release_id_and_component_id", unique: true
  end

  create_table "detected_components", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "detection_id"
    t.string "name"
    t.string "version"
    t.string "license_name"
    t.string "license_version"
    t.integer "component_id"
    t.integer "license_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "own", default: false
    t.boolean "purchased", default: false
    t.index ["detection_id"], name: "index_detected_components_on_detection_id"
  end

  create_table "detections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "acquired", default: false
    t.integer "release_id"
    t.string "parsed_file_name"
    t.datetime "parsed_file_at"
  end

  create_table "license_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "code", limit: 2
    t.string "description", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "protection_level"
    t.index ["code"], name: "index_license_types_on_code", unique: true
  end

  create_table "licenses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 15
    t.string "description", limit: 100
    t.string "version", limit: 5
    t.integer "category_id"
    t.integer "license_type_id"
    t.boolean "flag_osi", default: true
    t.text "text_license"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "notes"
    t.integer "similar_license_id"
    t.index ["category_id"], name: "index_licenses_on_category_id"
    t.index ["description"], name: "index_licenses_on_description"
    t.index ["license_type_id"], name: "index_licenses_on_type_id"
    t.index ["name", "version"], name: "index_licenses_on_name_and_version", unique: true
  end

  create_table "log_entries", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "user"
    t.string "object"
    t.string "operation"
    t.datetime "date"
    t.string "product"
    t.string "product_release"
    t.string "detection"
    t.string "detected_component"
    t.string "component"
    t.string "version"
    t.string "license"
    t.string "license_previous"
    t.string "license_name_previous"
    t.string "similar_license"
    t.string "similar_license_previous"
    t.string "license_type"
    t.string "license_type_previous"
    t.boolean "own"
    t.boolean "own_previous"
    t.boolean "purchased"
    t.boolean "purchased_previous"
    t.boolean "leave_out"
    t.boolean "leave_out_previous"
  end

  create_table "products", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 30
    t.string "title", limit: 100
    t.text "description"
    t.integer "use_id"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "groupage", limit: 25
    t.date "last_release_checked_at"
    t.boolean "last_release_check_result"
    t.string "last_release_version_name", limit: 25
    t.index ["name"], name: "index_products_on_name_and_version", unique: true
    t.index ["title"], name: "index_products_on_title"
    t.index ["use_id"], name: "index_products_on_use_id"
  end

  create_table "releases", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "product_id"
    t.string "version_name", limit: 25
    t.decimal "sequential_number", precision: 9, scale: 3
    t.integer "license_id"
    t.boolean "check_result"
    t.date "checked_at"
    t.integer "compatible_license_id"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rule_entries", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "rule_id"
    t.integer "license_id"
    t.boolean "plus"
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_rule_entries_on_order_id"
  end

  create_table "rules", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "license_id"
    t.boolean "plus"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["license_id"], name: "index_rules_on_license_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "uses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name", limit: 5
    t.string "description", limit: 100
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_uses_on_name", unique: true
  end

end
