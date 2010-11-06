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

ActiveRecord::Schema.define(:version => 20101105115556) do

  create_table "meego_test_cases", :force => true do |t|
    t.integer "meego_test_set_id",                     :null => false
    t.string  "name",                                  :null => false
    t.integer "result",                                :null => false
    t.string  "comment",               :default => ""
    t.integer "meego_test_session_id", :default => 0,  :null => false
  end

  add_index "meego_test_cases", ["meego_test_session_id"], :name => "index_meego_test_cases_on_meego_test_session_id"
  add_index "meego_test_cases", ["meego_test_set_id"], :name => "index_meego_test_cases_on_meego_test_set_id"

  create_table "meego_test_sessions", :force => true do |t|
    t.string   "environment",                       :default => ""
    t.string   "hwproduct",                         :default => ""
    t.string   "xmlpath",                           :default => ""
    t.string   "title",                                                :null => false
    t.string   "target",                            :default => ""
    t.string   "testtype",                          :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "objective_txt",     :limit => 4000, :default => "",    :null => false
    t.string   "build_txt",         :limit => 4000, :default => "",    :null => false
    t.string   "qa_summary_txt",    :limit => 4000, :default => "",    :null => false
    t.string   "issue_summary_txt", :limit => 4000, :default => "",    :null => false
    t.boolean  "published",                         :default => false
    t.string   "environment_txt",   :limit => 4000, :default => "",    :null => false
    t.datetime "tested_at",                                            :null => false
    t.integer  "author_id",                         :default => 0,     :null => false
    t.integer  "editor_id",                         :default => 0,     :null => false
    t.integer  "total_cases",                       :default => 0,     :null => false
    t.integer  "total_pass",                        :default => 0,     :null => false
    t.integer  "total_fail",                        :default => 0,     :null => false
    t.integer  "total_na",                          :default => 0,     :null => false
    t.string   "release_version",                   :default => "",    :null => false
  end

  create_table "meego_test_sets", :force => true do |t|
    t.string  "feature",               :default => ""
    t.integer "total_cases",           :default => 0,  :null => false
    t.integer "total_pass",            :default => 0,  :null => false
    t.integer "total_fail",            :default => 0,  :null => false
    t.integer "total_na",              :default => 0,  :null => false
    t.integer "meego_test_session_id", :default => 0,  :null => false
  end

  add_index "meego_test_sets", ["feature"], :name => "index_meego_test_sets_on_feature"
  add_index "meego_test_sets", ["meego_test_session_id"], :name => "index_meego_test_sets_on_meego_test_session_id"

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "default_target",                     :default => "", :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
