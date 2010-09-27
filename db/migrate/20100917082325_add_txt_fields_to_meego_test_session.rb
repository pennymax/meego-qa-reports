class AddTxtFieldsToMeegoTestSession < ActiveRecord::Migration
  def self.up
    add_column :meego_test_sessions, :objective_txt, :string, :default => ""
    add_column :meego_test_sessions, :build_txt, :string, :default => ""
    add_column :meego_test_sessions, :qa_summary_txt, :string, :default => ""
    add_column :meego_test_sessions, :issue_summary_txt, :string, :default => ""
  end

  def self.down
    remove_column :meego_test_sessions, :objective_txt
    remove_column :meego_test_sessions, :build_txt
    remove_column :meego_test_sessions, :qa_summary_txt
    remove_column :meego_test_sessions, :issue_summary_txt
  end
end
