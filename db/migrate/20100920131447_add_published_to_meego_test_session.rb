class AddPublishedToMeegoTestSession < ActiveRecord::Migration
  def self.up
    add_column :meego_test_sessions, :published, :boolean, :default => false
  end

  def self.down
    remove_column :meego_test_sessions, :published
  end
end
