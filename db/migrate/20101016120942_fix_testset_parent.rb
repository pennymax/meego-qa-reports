class FixTestsetParent < ActiveRecord::Migration
  def self.up
    change_table :meego_test_sets do |t|
      t.remove :meego_test_suite_id
      t.integer :meego_test_session_id, :null => false, :default => 0
    end
  end

  def self.down
  end
end
