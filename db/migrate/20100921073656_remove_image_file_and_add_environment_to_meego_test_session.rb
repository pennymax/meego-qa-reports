class RemoveImageFileAndAddEnvironmentToMeegoTestSession < ActiveRecord::Migration
  def self.up
    remove_column :meego_test_sessions, :imagefile
    add_column :meego_test_sessions, :environment_txt, :string, :default => ""
  end

  def self.down
    remove_column :meego_test_sessions, :environment_txt
    add_column    :meego_test_sessions, :imagefile, :string, :null => false
  end
end
