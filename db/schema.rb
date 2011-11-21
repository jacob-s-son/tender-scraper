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

ActiveRecord::Schema.define(:version => 20111121113724) do

  create_table "proxy_servers", :force => true do |t|
    t.string   "ip"
    t.string   "port"
    t.integer  "priority"
    t.boolean  "black_listed_flag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tenders", :force => true do |t|
    t.string   "url"
    t.string   "registration_number"
    t.string   "buyer_name"
    t.string   "address"
    t.string   "city"
    t.string   "post_code"
    t.string   "country"
    t.string   "contact"
    t.string   "phone_number"
    t.string   "mobile_phone_number"
    t.string   "fax_number"
    t.string   "email"
    t.string   "website"
    t.string   "heading"
    t.text     "cpv_codes"
    t.string   "procurement_procedure"
    t.string   "case_number"
    t.string   "nuts_code"
    t.date     "publication_date"
    t.date     "closing_date"
    t.string   "closing_time"
    t.date     "opening_date"
    t.string   "opening_time"
    t.date     "material_closing_date"
    t.string   "material_closing_time"
    t.string   "assignment"
    t.string   "attachment"
    t.string   "tender_type"
    t.string   "sector"
    t.string   "value"
    t.text     "document"
    t.integer  "exported_times"
    t.time     "exported_at"
    t.integer  "last_time_exported_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "last_time_edited_by"
    t.boolean  "marked_for_export"
    t.string   "lock_status"
    t.string   "status"
    t.datetime "locked_at"
    t.string   "locked_by"
  end

end
