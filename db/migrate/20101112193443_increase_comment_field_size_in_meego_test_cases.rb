class IncreaseCommentFieldSizeInMeegoTestCases < ActiveRecord::Migration
  def self.up
    change_column :meego_test_cases, :comment, :string, :limit => 1000, :null => false
  end

  def self.down
    change_column :meego_test_cases, :comment, :string, :limit => 256
  end
end
