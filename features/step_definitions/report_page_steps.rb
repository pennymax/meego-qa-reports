require 'db_state'

Then /^I should see the following table:$/ do |expected_report_front_pages_table|
  expected_report_front_pages_table.diff!(tableish('table tr', 'td,th'))
end

When /I view the report id (\d+)/ do |report_id|
  visit("report/view/#{report_id}")
end

Given /^I have created the "([^"]*)" report$/ do |report_name|
  DBState.load(File.join("features/resources/#{report_name}_state.sql"))
end