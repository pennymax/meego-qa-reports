class FixTestSessionDefaultVersion < ActiveRecord::Migration
  def self.up
    change_column :meego_test_sessions, :release_version, :string, :default => "", :null => false
  end

  def self.down
  end
end
