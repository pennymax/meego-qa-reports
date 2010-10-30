class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :meego_test_cases, :meego_test_set_id
    add_index :meego_test_cases, :meego_test_session_id
    
    add_index :meego_test_sessions, [:release_version, :target, :testtype, :hwproduct]

    add_index :meego_test_sets, :meego_test_session_id
    add_index :meego_test_sets, :feature

    add_index :users, :email, :unique => true
  end

  def self.down
    remove_index  :meego_test_cases, :meego_test_set_id
    remove_index :meego_test_cases, :meego_test_session_id
    
    remove_index :meego_test_sessions, [:release_version, :target, :testtype, :hwproduct]

    remove_index :meego_test_sets, :meego_test_session_id
    remove_index :meego_test_sets, :feature

    remove_index :users, :email
  end
end
