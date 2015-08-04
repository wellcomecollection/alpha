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

ActiveRecord::Schema.define(version: 20150804132037) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"
  enable_extension "pg_stat_statements"
  enable_extension "hstore"

  create_table "collections", force: :cascade do |t|
    t.text    "name",                             null: false
    t.text    "code",                             null: false
    t.integer "records",              default: 0, null: false
    t.integer "parent_collection_id"
    t.integer "record_id"
    t.text    "sample_images",                                 array: true
    t.integer "digitized_records"
  end

  create_table "creators", force: :cascade do |t|
    t.integer  "record_id",  null: false
    t.integer  "person_id",  null: false
    t.text     "as"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "creators", ["record_id", "person_id"], name: "index_creators_on_record_id_and_person_id", unique: true, using: :btree

  create_table "fields", force: :cascade do |t|
    t.text    "tag",                              null: false
    t.integer "count",                            null: false
    t.integer "non_electronic_count", default: 0, null: false
  end

  add_index "fields", ["tag"], name: "index_fields_on_tag", unique: true, using: :btree

  create_table "people", force: :cascade do |t|
    t.text     "name",                       null: false
    t.text     "all_names",                               array: true
    t.integer  "records_count", default: 0,  null: false
    t.integer  "born_in"
    t.integer  "died_in"
    t.hstore   "identifiers",   default: {}, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "records", force: :cascade do |t|
    t.text    "title",                          null: false
    t.text    "identifier",                     null: false
    t.jsonb   "metadata",          default: {}, null: false
    t.text    "leader",                         null: false
    t.text    "archives_ref"
    t.jsonb   "image_manifest"
    t.text    "cover_image_uris",                            array: true
    t.text    "title_page_uris",                             array: true
    t.jsonb   "package"
    t.text    "access_conditions"
    t.text    "year"
    t.boolean "digitized"
  end

  add_index "records", ["archives_ref"], name: "index_records_on_archives_ref", using: :btree
  add_index "records", ["digitized"], name: "index_records_on_digitized", using: :btree
  add_index "records", ["identifier"], name: "index_records_on_identifier", unique: true, using: :btree
  add_index "records", ["image_manifest"], name: "index_records_on_image_manifest", using: :gin
  add_index "records", ["metadata"], name: "index_records_on_metadata", using: :gin
  add_index "records", ["package"], name: "index_records_on_package", using: :gin
  add_index "records", ["year", "digitized"], name: "index_records_on_year_and_digitized", using: :btree
  add_index "records", ["year"], name: "index_records_on_year", using: :btree

  create_table "subfield_content_counts", force: :cascade do |t|
    t.integer "field_id",        null: false
    t.string  "subfield",        null: false
    t.string  "content",         null: false
    t.integer "count",           null: false
    t.integer "digitized_count"
  end

  add_index "subfield_content_counts", ["field_id", "subfield"], name: "index_subfield_content_counts_on_field_id_and_subfield", using: :btree

  create_table "subjects", force: :cascade do |t|
    t.text   "scheme"
    t.text   "identifier"
    t.text   "label"
    t.text   "description"
    t.text   "all_labels",                                    array: true
    t.text   "related_identifiers",                           array: true
    t.text   "tree_numbers",                                  array: true
    t.hstore "identifiers",         default: {}, null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "record_id",  null: false
    t.integer "subject_id", null: false
    t.text    "label"
  end

end
