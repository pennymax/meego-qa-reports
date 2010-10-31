class AddDefaultTargetForUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :default_target, :string, :default => "", :null => false
  end

  def self.down
    remove_column :users, :default_target
  end
end
