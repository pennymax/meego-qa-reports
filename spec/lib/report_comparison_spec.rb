require 'spec_helper'
require 'report_comparison'
require 'rspec/rails/mocks.rb'

class ReportComparisonSpec < ActiveSupport::TestCase
  
  describe ReportComparison do
    before(:each) do
      user = User.new({
          :email => "test@test.com",
          :password => "foobar",
          :name => "TestUser"
      })
      @session1 = MeegoTestSession.import({
          :author => user,
          :title => "Test1",
          :target => "Core",
          :testtype => "Sanity",
          :hwproduct => "N900"
      }, [File.new("spec/fixtures/sim1.xml")], user)

      @session2 = MeegoTestSession.import({
          :author => user,
          :title => "Test1",
          :target => "Core",
          :testtype => "Sanity Testing",
          :hwproduct => "N900"
      }, [File.new("spec/fixtures/sim2.xml")], user)
    end

    it "should compare two reports and list changed tests" do
      comparison = ReportComparison.new(@session1, @session2)
      results = comparison.changed_test_cases
      results[0].name.should == "SMOKE-SIM-Query_SIM_card_status"
      results[1].name.should == "SMOKE-SIM-Get_IMSI"
      results[2].name.should == "SMOKE-SIM-Query_Service_Provider_name"
      results.length.should == 3
    end
  end
end