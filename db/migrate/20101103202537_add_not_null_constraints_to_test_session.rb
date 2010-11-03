class AddNotNullConstraintsToTestSession < ActiveRecord::Migration
  def self.up
    change_column :meego_test_sessions, 
      :objective_txt, 
      :string, 
      :limit => 4000, 
      :default => "", 
      :null => false
    
    change_column :meego_test_sessions, 
      :environment_txt, 
      :string, 
      :limit => 4000, 
      :default => "", 
      :null => false
    
    change_column :meego_test_sessions, 
      :build_txt, 
      :string, 
      :limit => 4000, 
      :default => "", 
      :null => false

    change_column :meego_test_sessions, 
      :qa_summary_txt, 
      :string, 
      :limit => 4000, 
      :default => "", 
      :null => false

    change_column :meego_test_sessions, 
      :issue_summary_txt, 
      :string, 
      :limit => 4000, 
      :default => "", 
      :null => false
  end

  def self.down
    # No down migration needed
    change_column :meego_test_sessions, 
      :objective_txt, 
      :string, 
      :limit => 4000, 
      :default => ""
    
    change_column :meego_test_sessions, 
      :environment_txt, 
      :string, 
      :limit => 4000, 
      :default => ""
    
    change_column :meego_test_sessions, 
      :build_txt, 
      :string, 
      :limit => 4000, 
      :default => ""

    change_column :meego_test_sessions, 
      :qa_summary_txt, 
      :string, 
      :limit => 4000, 
      :default => ""

    change_column :meego_test_sessions, 
      :issue_summary_txt, 
      :string, 
      :limit => 4000, 
      :default => ""
  end
end
