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

ActiveRecord::Schema[7.1].define(version: 2026_07_28_161100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"
  enable_extension "vector"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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

  create_table "brands", force: :cascade do |t|
    t.string "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_brands_on_title", unique: true
  end

  create_table "catalog_item_nodes", force: :cascade do |t|
    t.bigint "node_id", null: false
    t.bigint "catalog_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catalog_item_id"], name: "index_catalog_item_nodes_on_catalog_item_id"
    t.index ["node_id", "catalog_item_id"], name: "index_catalog_item_nodes_on_node_id_and_catalog_item_id", unique: true
    t.index ["node_id"], name: "index_catalog_item_nodes_on_node_id"
  end

  create_table "catalog_items", force: :cascade do |t|
    t.string "title", null: false
    t.bigint "brand_id", null: false
    t.string "model"
    t.bigint "country_id"
    t.integer "production_start_year"
    t.integer "production_end_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "to_tsvector('simple'::regconfig, immutable_unaccent((title)::text))", name: "index_catalog_items_on_title_tsvector", using: :gin
    t.index ["brand_id"], name: "index_catalog_items_on_brand_id"
    t.index ["country_id"], name: "index_catalog_items_on_country_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_countries_on_name", unique: true
  end

  create_table "gallery_items", force: :cascade do |t|
    t.string "gallery_type", null: false
    t.bigint "gallery_id", null: false
    t.text "description"
    t.boolean "cover", default: false, null: false
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gallery_type", "gallery_id", "cover"], name: "index_gallery_items_on_gallery_type_and_gallery_id_and_cover"
    t.index ["gallery_type", "gallery_id"], name: "index_gallery_items_on_gallery_type_and_gallery_id"
  end

  create_table "nodes", force: :cascade do |t|
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.vector "embedding", limit: 1536
    t.bigint "parent_id"
    t.string "title"
    t.integer "position"
    t.integer "visibility_level", default: 0, null: false
    t.bigint "user_id", null: false
    t.text "content"
    t.virtual "content_tsv", type: :tsvector, as: "(setweight(to_tsvector('french'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::\"char\") || setweight(to_tsvector('french'::regconfig, COALESCE(content, ''::text)), 'B'::\"char\"))", stored: true
    t.index ["content_tsv"], name: "index_nodes_on_content_tsv", using: :gin
    t.index ["parent_id"], name: "index_nodes_on_parent_id"
    t.index ["user_id"], name: "index_nodes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "display_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "catalog_item_nodes", "catalog_items"
  add_foreign_key "catalog_item_nodes", "nodes"
  add_foreign_key "catalog_items", "brands"
  add_foreign_key "catalog_items", "countries"
  add_foreign_key "nodes", "users"
end
