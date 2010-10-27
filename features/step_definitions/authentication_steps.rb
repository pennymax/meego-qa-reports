Given /^I am a new, authenticated user$/ do
  email = 'testing@man.net'
  password = 'secretpass'

  Given %{I have one user "John Longbottom" with email "#{email}" and password "#{password}"}
  When %{I log in with email "#{email}" and password "#{password}"}
end

Given /^I have (?:one )?user "([^\"]*)" with email "([^\"]*)" and password "([^\"]*)"$/ do
  |name, email, password|

  User.delete_all("email = '#{email}'")
  User.new(:name => name,
           :email => email,
           :password => password,
           :password_confirmation => password).save!
end

Given /^I'm not logged in$/ do
  visit('/users/sign_out')  
end

When /^I log in with email "([^\"]*)" and password "([^\"]*)"$/ do |email, password|
  And %{I go to login}
  And %{I fill in "user_email" with "#{email}"}
  And %{I fill in "user_password" with "#{password}"}
  And %{I press "Login"}
end

Then /^I should return to report "([^\"]*)" and see "([^\"]*)" and a "Log out" button$/ do
  |report_string, user_name|

  # TODO: DRY
  target, test_type, hardware = report_string.split('/')
  report = MeegoTestSession.first(:conditions =>
   {:target => target, :hwproduct => hardware, :testtype => test_type}
  )

  current_path.should == "/report/view/#{report.id}"

  And %{I should see "#{user_name}" within "#session"}
end