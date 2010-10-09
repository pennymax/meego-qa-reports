Given /^the following report_front_pages:$/ do |report_front_pages|
  ReportFrontPage.create!(report_front_pages.hashes)
end

When /^I delete the (\d+)(?:st|nd|rd|th) report_front_page$/ do |pos|
  visit report_front_pages_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following report_front_pages:$/ do |expected_report_front_pages_table|
  expected_report_front_pages_table.diff!(tableish('table tr', 'td,th'))
end
