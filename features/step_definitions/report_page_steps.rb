Then /^I should see the following table:$/ do |expected_report_front_pages_table|
  expected_report_front_pages_table.diff!(tableish('table tr', 'td,th'))
end

Then /^I should see the main navigation columns$/ do
  And %{I should see "Core" within "#report_navigation"}
  And %{I should see "Handset" within "#report_navigation"}
  And %{I should see "Netbook" within "#report_navigation"}
  And %{I should see "IVI" within "#report_navigation"}
end

When /^I should see the sign in link without ability to add report$/ do
  And %{I should see "Sign In"}
  And %{I should not see "Add report"}
end

When /I view the report "([^"]*)"$/ do |report_string|
  target, test_type, hardware = report_string.split('/')
  report = MeegoTestSession.first(:conditions =>
   {:target => target, :hwproduct => hardware, :testtype => test_type}
  )
  raise "report not found with parameters #{target}/#{hardware}/#{test_type}!" unless report
  visit("/report/view/#{report.id}")
end

Given /^I have created the "([^"]*)" report$/ do |report_name|

  target, test_type, hardware = report_name.split('/')

  Given "I am on the front page"
  When %{I follow "Add report"}
  And %{I select target "#{target}", test type "#{test_type}" and hardware "#{hardware}"}
  And %{I attach the report "sample.csv"}
  And %{I submit the form at "upload_report_submit"}
  And %{I submit the form at "upload_report_submit"}
end

Given /^there exists a report for "([^"]*)"$/ do |report_name|
  target, test_type, hardware = report_name.split('/')

  fpath = File.join(Rails.root, "features", "resources", "sample.csv")

  user = User.create!(:name => "John Longbottom",
    :email => "email@email.com",
    :password => "password",
    :password_confirmation => "password")

  session = MeegoTestSession.new(:target => target, :hwproduct => hardware,
    :testtype => test_type, :uploaded_files => [fpath],
    :tested_at => Time.now, :author => user, :editor => user
  )
  session.generate_defaults! # Is this necessary, or could we just say create! above?
  session.save!
end


When /^I click to edit the report$/ do
  When "I follow \"edit-button\" within \"#edit_report\""
end

When /^I click to print the report$/ do
  When "I follow \"print-button\" within \"#edit_report\""
end

When /^I click to delete the report$/ do
  When "I follow \"delete-button\" within \"#edit_report\""
end

When /^I attach the report "([^"]*)"$/ do |file|
  And "attach the file \"features/resources/#{file}\" to \"meego_test_session[uploaded_files][]\" within \"#browse\""
end

When /^I select target "([^\"]*)", test type "([^\"]*)" and hardware "([^\"]*)" with date "([^\"]*)"$/ do |tgt, ttype, hw, date|
  When %{I fill in "report_test_execution_date" with "#{date}"}
  When %{I select target "#{tgt}", test type "#{ttype}" and hardware "#{hw}"}
end

Given /^I select target "([^"]*)", test type "([^"]*)" and hardware "([^"]*)"$/ do |target, test_type, hardware|
  When %{I choose "#{target}"}
  When "I fill in \"meego_test_session[testtype]\" with \"#{test_type}\""
  When "I fill in \"meego_test_session[hwproduct]\" with \"#{hardware}\""
end

Given /^I select test type "([^"]*)" and hardware "([^"]*)"$/ do |test_type, hardware|
  When %{I fill in "meego_test_session[testtype]" with "#{test_type}"}
  When %{I fill in "meego_test_session[hwproduct]" with "#{hardware}"}
end

Then /^I should see the header$/ do
  Then "I should see \"QA Reports\" within \"#header\""
end

Then /^I should not see the header$/ do
  Then "I should not see \"#header\""
end
