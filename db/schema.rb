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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120410035927) do

  create_table "achievements", :force => true do |t|
    t.string   "email"
    t.integer  "points"
    t.integer  "currency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "email"
    t.date     "expiry"
    t.decimal  "lat",                :precision => 15, :scale => 10
    t.decimal  "lng",                :precision => 15, :scale => 10
    t.integer  "validated"
    t.integer  "event_id"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "validation_hash"
    t.string   "venue_id"
    t.text     "media"
  end

end
