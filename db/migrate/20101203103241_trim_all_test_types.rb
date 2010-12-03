class TrimAllTestTypes < ActiveRecord::Migration
  def self.up
    sessions = MeegoTestSession.find(:all)
    sessions.each do |s|
      s.testtype = s.testtype.strip()
      s.save
    end
  end

  def self.down
  end
end
