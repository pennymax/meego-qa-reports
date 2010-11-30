class OneTimeTesttypeValueFix < ActiveRecord::Migration
  def self.up
    sessions = MeegoTestSession.find(:all, :conditions => {:testtype => 'acceptance '})
    sessions.each do |s|
      s.testtype = 'acceptance'
      s.save
    end
  end

  def self.down
  end
end
