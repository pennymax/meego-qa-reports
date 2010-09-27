class CreateTestCases < ActiveRecord::Migration
  def self.up
    create_table :meego_test_cases do |t|
      t.integer :meego_test_set_id, :null => false
      t.string :name, :null => false
      t.string :description, :default => ""
      t.boolean :manual, :default => false
      t.boolean :insignificant, :default => false
      t.integer :result, :null => false
      t.string :subfeature, :default => ""
      
      t.string :comment, :default => ""
      t.integer :ref_id
    end
  end

  def self.down
    drop_table :test_cases
  end
end
