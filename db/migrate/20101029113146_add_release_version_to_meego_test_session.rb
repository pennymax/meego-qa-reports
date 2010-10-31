class AddReleaseVersionToMeegoTestSession < ActiveRecord::Migration
  def self.up
    add_column :meego_test_sessions, :release_version, :string, :default => "1.1"
  end

  def self.down
    remove_column :meego_test_sessions, :release_version
  end
end
