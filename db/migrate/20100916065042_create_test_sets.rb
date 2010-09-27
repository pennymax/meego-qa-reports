class CreateTestSets < ActiveRecord::Migration
  def self.up
    create_table :meego_test_sets do |t|
      t.integer :meego_test_suite_id, :null => false
      t.string :name, :null => false
      t.string :description, :default => ""
      t.string :environment, :default => ""
      t.string :feature, :default => ""
      
      t.integer :ref_id
    end
  end

  def self.down
    drop_table :test_sets
  end
end
