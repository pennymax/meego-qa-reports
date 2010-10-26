Then /^I should see the following table:$/ do |expected_report_front_pages_table|
  expected_report_front_pages_table.diff!(tableish('table tr', 'td,th'))
end

Then /^I should see the main navigation columns$/ do
  %{And I should see "Core" within "#report_navigation"}
  %{And I should see "Handset" within "#report_navigation"}
  %{And I should see "Netbook" within "#report_navigation"}
  %{And I should see "IVI" within "#report_navigation"}
end

When /^I should see the sign in link without ability to add report$/ do
  %{And I should see "Sign In"}
  %{And I should not see "Add report"}
end