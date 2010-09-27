class AddMeegoTestSessionIdToMeegoTestCase < ActiveRecord::Migration
  def self.up
    add_column :meego_test_cases, :meego_test_session_id, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :meego_test_cases, :meego_test_session_id
  end
end
