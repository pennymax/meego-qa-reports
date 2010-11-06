require 'spec_helper'

describe MeegoTestSession do
  it "should accept valid tested_at date" do
    ['2010-07-15', '2010-11-4', '2011-12-30 23:45:59'].each do |date|
      mts = MeegoTestSession.new(:tested_at => date)
      mts.valid? # called for side effects
      mts.errors[:tested_at].should be_empty
    end
  end

  it "should not accept empty tested_at string" do
      mts = MeegoTestSession.new(:tested_at => '')
      mts.should_not be_valid
  end

  it "should fail to accept invalid tested_at date" do
    mts = MeegoTestSession.new(:tested_at => '2010-13-15')
    mts.should_not be_valid
    mts.errors[:tested_at].should_not be_empty
  end
end
