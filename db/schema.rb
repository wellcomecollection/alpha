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

ActiveRecord::Schema.define(version: 20160513104131) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"
  enable_extension "pg_stat_statements"
  enable_extension "unaccent"

  create_table "collection_memberships", force: :cascade do |t|
    t.integer "collection_id"
    t.integer "record_id"
  end

  add_index "collection_memberships", ["collection_id", "record_id"], name: "index_collection_memberships_on_collection_id_and_record_id", unique: true, using: :btree
  add_index "collection_memberships", ["collection_id"], name: "index_collection_memberships_on_collection_id", using: :btree

  create_table "collections", force: :cascade do |t|
    t.text     "name",                                    null: false
    t.integer  "records_count",           default: 0,     null: false
    t.integer  "parent_collection_id"
    t.integer  "record_id"
    t.text     "sample_images",                                        array: true
    t.text     "dig_code"
    t.integer  "digitized_records_count", default: 0,     null: false
    t.text     "description"
    t.text     "slug",                                    null: false
    t.integer  "from_year"
    t.integer  "to_year"
    t.boolean  "highlighted",             default: false, null: false
    t.text     "editorial_title"
    t.text     "editorial_content"
    t.datetime "editorial_updated_at"
    t.integer  "editorial_updated_by_id"
    t.boolean  "hidden",                  default: false, null: false
  end

  add_index "collections", ["dig_code"], name: "index_collections_on_dig_code", unique: true, using: :btree
  add_index "collections", ["slug"], name: "index_collections_on_slug", unique: true, using: :btree

  create_table "creators", force: :cascade do |t|
    t.integer  "record_id",  null: false
    t.integer  "person_id",  null: false
    t.text     "as"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "creators", ["record_id", "person_id"], name: "index_creators_on_record_id_and_person_id", unique: true, using: :btree

  create_table "people", force: :cascade do |t|
    t.text     "name",                                         null: false
    t.text     "all_names",                                                 array: true
    t.integer  "records_count",                default: 0,     null: false
    t.integer  "born_in"
    t.integer  "died_in"
    t.hstore   "identifiers",                  default: {},    null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.text     "wikipedia_intro",                                           array: true
    t.text     "wikipedia_images",                                          array: true
    t.text     "wikipedia_intro_paragraph"
    t.text     "editorial_title"
    t.text     "editorial_content"
    t.datetime "editorial_updated_at"
    t.integer  "editorial_updated_by_id"
    t.text     "wellcome_intro"
    t.datetime "wellcome_intro_updated_at"
    t.integer  "wellcome_intro_updated_by_id"
    t.boolean  "highlighted",                  default: false, null: false
    t.integer  "records_as_subject_count",     default: 0,     null: false
  end

  add_index "people", ["highlighted"], name: "index_people_on_highlighted", where: "(highlighted IS TRUE)", using: :btree

  create_table "people_as_subjects", force: :cascade do |t|
    t.integer "record_id"
    t.integer "person_id"
    t.string  "as",        null: false
  end

  add_index "people_as_subjects", ["person_id"], name: "index_people_as_subjects_on_person_id", using: :btree
  add_index "people_as_subjects", ["record_id", "person_id"], name: "index_people_as_subjects_on_record_id_and_person_id", unique: true, using: :btree

  create_table "record_types", force: :cascade do |t|
    t.integer "record_id", null: false
    t.integer "type_id",   null: false
  end

  add_index "record_types", ["record_id", "type_id"], name: "index_record_types_on_record_id_and_type_id", unique: true, using: :btree
  add_index "record_types", ["type_id"], name: "index_record_types_on_type_id", using: :btree

  create_table "records", force: :cascade do |t|
    t.text     "title",                                    null: false
    t.text     "identifier",                               null: false
    t.jsonb    "metadata",                 default: {},    null: false
    t.text     "leader"
    t.text     "archives_ref"
    t.text     "cover_image_uris",                                      array: true
    t.text     "title_page_uris",                                       array: true
    t.jsonb    "package"
    t.text     "access_conditions"
    t.text     "year"
    t.boolean  "digitized",                default: false, null: false
    t.text     "pdf_thumbnail_url"
    t.integer  "creators_count",           default: 0,     null: false
    t.hstore   "identifiers",              default: {},    null: false
    t.integer  "types_count",              default: 0,     null: false
    t.integer  "parent_id"
    t.integer  "people_as_subjects_count", default: 0,     null: false
    t.datetime "digitized_at"
    t.text     "rights"
  end

  add_index "records", ["archives_ref"], name: "index_records_on_archives_ref", using: :btree
  add_index "records", ["digitized"], name: "index_records_on_digitized", using: :btree
  add_index "records", ["identifier"], name: "index_records_on_identifier", unique: true, using: :btree
  add_index "records", ["parent_id"], name: "index_records_on_parent_id", using: :btree
  add_index "records", ["types_count"], name: "index_records_on_types_count", using: :btree
  add_index "records", ["year", "digitized"], name: "index_records_on_year_and_digitized", using: :btree
  add_index "records", ["year"], name: "index_records_on_year", using: :btree

  create_table "subjects", force: :cascade do |t|
    t.text     "scheme"
    t.text     "label"
    t.text     "description"
    t.text     "all_labels",                                                array: true
    t.text     "related_identifiers",                                       array: true
    t.text     "tree_numbers",                                              array: true
    t.hstore   "identifiers",                  default: {},    null: false
    t.integer  "records_count",                default: 0,     null: false
    t.integer  "digitized_records_count",      default: 0,     null: false
    t.text     "wellcome_intro"
    t.datetime "wellcome_intro_updated_at"
    t.integer  "wellcome_intro_updated_by_id"
    t.boolean  "highlighted",                  default: false, null: false
  end

  add_index "subjects", ["highlighted"], name: "index_subjects_on_highlighted", where: "(highlighted IS TRUE)", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer "record_id",  null: false
    t.integer "subject_id", null: false
    t.text    "label"
  end

  add_index "taggings", ["record_id", "subject_id"], name: "index_taggings_on_record_id_and_subject_id", unique: true, using: :btree
  add_index "taggings", ["subject_id"], name: "index_taggings_on_subject_id", using: :btree

  create_table "types", force: :cascade do |t|
    t.text    "name",                                    null: false
    t.text    "description"
    t.text    "references",              default: [],    null: false, array: true
    t.integer "records_count",           default: 0,     null: false
    t.integer "digitized_records_count", default: 0,     null: false
    t.boolean "highlighted",             default: false, null: false
  end

  add_index "types", ["name"], name: "index_types_on_name", unique: true, using: :btree
  add_index "types", ["references"], name: "index_types_on_references", using: :btree

  create_table "users", force: :cascade do |t|
    t.text     "email",                           null: false
    t.text     "password_digest",                 null: false
    t.boolean  "admin",           default: false, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
