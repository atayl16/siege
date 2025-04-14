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

ActiveRecord::Schema[7.0].define(version: 2025_04_14_134502) do
  create_table "achievements", force: :cascade do |t|
    t.integer "wom_id"
    t.string "name"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "player_name"
  end

  create_table "bingos", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "events", force: :cascade do |t|
    t.integer "wom_id"
    t.string "name"
    t.datetime "starts"
    t.datetime "ends"
    t.string "metric"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "winner"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.integer "xp"
    t.integer "lvl"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "rank"
    t.integer "current_lvl", default: 0
    t.integer "current_xp", default: 0
    t.integer "first_xp"
    t.integer "first_lvl"
    t.bigint "gained_xp"
    t.json "old_names"
    t.integer "wom_id"
    t.string "wom_name"
    t.integer "score"
    t.boolean "inactive", default: false
    t.boolean "deactivated", default: false
    t.integer "deactivated_xp"
    t.integer "deactivated_lvl"
    t.datetime "deactivated_date"
    t.integer "reactivated_xp"
    t.integer "reactivated_lvl"
    t.datetime "reactivated_date"
    t.datetime "joined_date"
    t.integer "combat", default: 0
    t.string "build"
    t.string "achievement_name"
    t.datetime "achievement_date"
    t.json "achievements"
    t.integer "siege_winner_place", default: 0
    t.integer "team_id"
    t.json "competition_1", default: {}
    t.json "competition_2", default: {}
    t.json "competition_3", default: {}
    t.json "competition_4", default: {}
    t.json "competition_5", default: {}
    t.json "competition_6", default: {}
    t.integer "ehb", default: 0
    t.string "womrole"
    t.boolean "runewatch_reported", default: false
    t.boolean "runewatch_whitelisted", default: false
    t.text "runewatch_whitelist_reason"
    t.datetime "runewatch_whitelisted_at"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.integer "bingo_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "player_ids"
    t.index ["bingo_id"], name: "index_teams_on_bingo_id"
  end

  create_table "tiles", force: :cascade do |t|
    t.string "name"
    t.string "image"
    t.text "description"
    t.integer "count"
    t.string "query"
    t.integer "order"
    t.integer "bingo_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bingo_id"], name: "index_tiles_on_bingo_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "vars", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "players", "teams"
  add_foreign_key "teams", "bingos"
  add_foreign_key "teams", "players", column: "player_ids"
  add_foreign_key "tiles", "bingos"
end
