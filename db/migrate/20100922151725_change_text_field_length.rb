class ChangeTextFieldLength < ActiveRecord::Migration
  def self.up
    change_column :meego_test_sessions, :objective_txt, :text, :default => "", :length => 4000
    change_column :meego_test_sessions, :build_txt, :text, :default => "", :length => 4000
    change_column :meego_test_sessions, :qa_summary_txt, :text, :default => "", :length => 4000
    change_column :meego_test_sessions, :issue_summary_txt, :text, :default => "", :length => 4000
    change_column :meego_test_sessions, :environment_txt, :text, :default => "", :length => 4000
  end

  def self.down
  end
end
