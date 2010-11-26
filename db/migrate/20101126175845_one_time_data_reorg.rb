class OneTimeDataReorg < ActiveRecord::Migration
  def self.up
    sessions = MeegoTestSession.find(:all, :conditions => {:hwproduct => 'nokia n900'})
    sessions.each do |s|
      s.hwproduct = 'N900'
      s.save
    end

    sessions = MeegoTestSession.find(:all, :conditions => {:target => 'handset', :testtype => 'dataflow', :hwproduct => 'n900'})
    sessions.each do |s|
      s.target = 'Core'
      s.save
    end

    sessions = MeegoTestSession.find(:all, :conditions => {:testtype => 'preview', :target => 'core'})
    sessions.each do |s|
      s.testtype = 'Basic Feature Testing'
      s.save
    end

    sessions = MeegoTestSession.find(:all, :conditions => {:testtype => 'weekly', :target => 'core'})
    sessions.each do |s|
      s.testtype = 'Dataflow'
      s.save
    end
  end

  def self.down
  end
end
