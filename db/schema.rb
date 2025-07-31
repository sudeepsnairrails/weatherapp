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

ActiveRecord::Schema[7.1].define(version: 2024_01_01_000002) do
  create_table "addresses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "full_address", null: false
    t.string "zip_code", null: false
    t.decimal "latitude", precision: 10, scale: 8, null: false
    t.decimal "longitude", precision: 11, scale: 8, null: false
    t.string "city"
    t.string "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["full_address"], name: "index_addresses_on_full_address", unique: true
    t.index ["zip_code"], name: "index_addresses_on_zip_code"
  end

  create_table "weather_forecasts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "zip_code", null: false
    t.integer "temperature", null: false
    t.integer "high_temp", null: false
    t.integer "low_temp", null: false
    t.string "description", null: false
    t.json "extended_forecast"
    t.datetime "cached_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cached_at"], name: "index_weather_forecasts_on_cached_at"
    t.index ["zip_code"], name: "index_weather_forecasts_on_zip_code", unique: true
  end

end
