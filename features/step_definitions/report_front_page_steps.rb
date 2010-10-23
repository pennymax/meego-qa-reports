Then /^I should see the following table:$/ do |expected_report_front_pages_table|
  expected_report_front_pages_table.diff!(tableish('table tr', 'td,th'))
end

When /I view the "(.*?)" report page$/ do |report_name|
  #puts "report/list/#{report_name}"
  visit("report/view/1")
end

Given /^I have created the "([^\"]*)" report$/ do |report_name|
  puts report_name
end