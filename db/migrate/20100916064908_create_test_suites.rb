class CreateTestSuites < ActiveRecord::Migration
  def self.up
    create_table :meego_test_suites do |t|
      t.integer :meego_test_session_id, :null => false
      t.string :name, :null => false
      t.string :domain, :default => ""
      
      t.integer :ref_id
    end
  end

  def self.down
    drop_table :test_suites
  end
end
