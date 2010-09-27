class CreateTestSessions < ActiveRecord::Migration
  def self.up
    create_table :meego_test_sessions do |t|
      t.string :environment, :default => ""
      
      t.string :hwproduct, :default => ""
      t.string :hwbuild, :default => ""
      
      t.string :xmlpath, :default => ""

      t.string :title, :null => false
      t.string :imagefile, :null => false

      t.string :target, :default => ""
      t.string :testtype, :default => ""
      t.integer :ref_id

      t.timestamps
    end
  end

  def self.down
    drop_table :test_sessions
  end
end
