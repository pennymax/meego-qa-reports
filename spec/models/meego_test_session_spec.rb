require 'spec_helper'

describe MeegoTestSession do
  it "should accept valid tested_at date" do
    mts = MeegoTestSession.new(:tested_at => '2010-07-15')
    mts.valid? # called for side effects
    mts.errors[:tested_at].should be_empty

  end

  it "should fail to accept invalid tested_at date" do
    mts = MeegoTestSession.new(:tested_at => '2010-13-15')
    mts.should_not be_valid
    mts.errors[:tested_at].should_not be_empty
  end
end
