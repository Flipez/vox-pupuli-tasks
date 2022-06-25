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

ActiveRecord::Schema.define(version: 2022_06_25_195434) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "labels", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.bigint "pull_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.index ["pull_request_id"], name: "index_labels_on_pull_request_id"
  end

  create_table "labels_pull_requests", id: false, force: :cascade do |t|
    t.integer "label_id", null: false
    t.integer "pull_request_id", null: false
  end

  create_table "pull_requests", force: :cascade do |t|
    t.integer "number"
    t.string "state"
    t.string "title"
    t.string "body"
    t.datetime "gh_created_at"
    t.datetime "gh_updated_at"
    t.datetime "closed_at"
    t.datetime "merged_at"
    t.bigint "repository_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "mergeable"
    t.integer "gh_repository_id"
    t.integer "github_id"
    t.string "author"
    t.boolean "eligible_for_merge_comment", default: true
    t.string "status"
    t.boolean "draft", default: false
    t.boolean "eligible_for_ci_comment", default: true
    t.string "conclusion"
    t.index ["github_id"], name: "index_pull_requests_on_github_id", unique: true
    t.index ["repository_id"], name: "index_pull_requests_on_repository_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.string "name"
    t.string "full_name"
    t.string "description"
    t.string "homepage"
    t.integer "stars"
    t.integer "watchers"
    t.integer "open_issues_count"
    t.integer "github_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "todos", default: {}
    t.json "vpt_config", default: {}
    t.index ["github_id"], name: "index_repositories_on_github_id", unique: true
    t.index ["name"], name: "index_repositories_on_name", unique: true
  end

  create_table "repository_statuses", force: :cascade do |t|
    t.json "checks", default: {}
    t.integer "repository_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string "var", null: false
    t.text "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "avatar_url"
    t.string "email"
    t.string "nickname"
    t.string "uid"
    t.string "provider"
    t.string "oauth_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "labels", "pull_requests"
  add_foreign_key "pull_requests", "repositories"
end
