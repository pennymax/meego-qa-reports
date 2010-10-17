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

ActiveRecord::Schema.define(:version => 20101017182620) do

  create_table "meego_test_cases", :force => true do |t|
    t.integer "meego_test_set_id",                        :null => false
    t.string  "name",                                     :null => false
    t.string  "description",           :default => ""
    t.boolean "manual",                :default => false
    t.boolean "insignificant",         :default => false
    t.integer "result",                                   :null => false
    t.string  "subfeature",            :default => ""
    t.string  "comment",               :default => ""
    t.integer "ref_id"
    t.integer "meego_test_session_id", :default => 0,     :null => false
  end

  create_table "meego_test_sessions", :force => true do |t|
    t.string   "environment",                      :default => ""
    t.string   "hwproduct",                        :default => ""
    t.string   "hwbuild",                          :default => ""
    t.string   "xmlpath",                          :default => ""
    t.string   "title",                                               :null => false
    t.string   "target",                           :default => ""
    t.string   "testtype",                         :default => ""
    t.integer  "ref_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "objective_txt",     :limit => 255, :default => ""
    t.text     "build_txt",         :limit => 255, :default => ""
    t.text     "qa_summary_txt",    :limit => 255, :default => ""
    t.text     "issue_summary_txt", :limit => 255, :default => ""
    t.boolean  "published",                        :default => false
    t.text     "environment_txt",   :limit => 255, :default => ""
  end

  create_table "meego_test_sets", :force => true do |t|
    t.integer "meego_test_suite_id",                 :null => false
    t.string  "name",                                :null => false
    t.string  "description",         :default => ""
    t.string  "environment",         :default => ""
    t.string  "feature",             :default => ""
    t.integer "ref_id"
  end

  create_table "meego_test_suites", :force => true do |t|
    t.integer "meego_test_session_id",                 :null => false
    t.string  "name",                                  :null => false
    t.string  "domain",                :default => ""
    t.integer "ref_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                              :default => "", :null => false
    t.string   "encrypted_password",  :limit => 128, :default => "", :null => false
    t.string   "password_salt",                      :default => "", :null => false
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
