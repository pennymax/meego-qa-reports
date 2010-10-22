class RenameHardwareHwproduct < ActiveRecord::Migration
  def self.up
    change_table :meego_test_sessions do |t|
      t.rename :hardware, :hwproduct
    end
  end

  def self.down
  end
end
