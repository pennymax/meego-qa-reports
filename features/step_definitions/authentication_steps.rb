Given /^I am a new, authenticated user$/ do
  email = 'testing@man.net'
  password = 'secretpass'

  Given %{I have one user "John Longbottom" with email "#{email}" and password "#{password}"}
  When %{I log in with email "#{email}" and password "#{password}"}
end

Given /^I have (?:one )?user "([^\"]*)" with email "([^\"]*)" and password "([^\"]*)"( and token "([^"]*)")?$/ do
  |name, email, password, token_given, token|

  Given %{there is no user with email "#{email}"}  
  User.new(:name => name,
           :email => email,
           :password => password,
           :password_confirmation => password,
           :authentication_token => token).save!
end

When /^I sign up as "([^"]*)" with email "([^"]*)" and password "([^"]*)"( and password confirmation "([^"]*)")?$/ do
  |name, email, password, confirmation_given, password_confirmation|

  When %{I go to the signing up page}
  And %{I fill in "user_name" with "#{name}"}
  And %{I fill in "user_email" with "#{email}"}
  And %{I fill in "user_password" with "#{password}"}

  confirmation = confirmation_given ? password_confirmation : password

  And %{I fill in "user_password_confirmation" with "#{confirmation}"}
  And %{I press "Sign up"}
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

Then /^I should return to report "([^\"]*)" and see "([^\"]*)" and a "Sign out" button$/ do
  |report_string, user_name|

  # TODO: DRY
  version, target, test_type, hardware = report_string.downcase.split('/')
  report = MeegoTestSession.first(:conditions =>
   {:target => target, :hwproduct => hardware, :testtype => test_type, :release_version => version}
  )
  report.should_not be_nil

  current_path.should == "/#{version}/#{target}/#{test_type}/#{hardware}/#{report.id}"

  And %{I should see "#{user_name}" within "#session"}
  And %{I should see "Sign out" within "#session"}
end

Given /^there is no user with email "([^"]*)"$/ do |email|
  User.delete_all("email = '#{email}'")
end

Then /^there should be a user "([^"]*)" with email "([^"]*)"$/ do
  |name, email|
  
  User.exists?(:name => name, :email => email).should be_true
end

