class SchemaRedesign < ActiveRecord::Migration
  def self.up
    change_table :meego_test_sessions do |t|
      t.remove :hwbuild
      t.remove :ref_id
      
      t.rename :hwproduct, :hardware
      
      t.datetime :tested_at, :null => false
      
      t.integer  :author_id, :null => false
      t.integer  :editor_id, :null => false
      
      t.integer  :total_cases, :null => false, :default => 0
      t.integer  :total_pass, :null => false, :default => 0
      t.integer  :total_fail, :null => false, :default => 0
      t.integer  :total_na, :null => false, :default => 0
    end
    
    drop_table :meego_test_suites
    
    change_table :meego_test_sets do |t|
      t.remove :name
      t.remove :description
      t.remove :environment
      t.remove :ref_id
      
      t.integer  :total_cases, :null => false, :default => 0
      t.integer  :total_pass, :null => false, :default => 0
      t.integer  :total_fail, :null => false, :default => 0
      t.integer  :total_na, :null => false, :default => 0
    end
    
    change_table :meego_test_cases do |t|
      t.remove :manual
      t.remove :insignificant
      t.remove :description
      t.remove :subfeature
      t.remove :ref_id
      
      
    end
    
  end

  def self.down
  end
end
