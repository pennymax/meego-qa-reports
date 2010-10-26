Given /^I am a new, authenticated user$/ do
  email = 'testing@man.net'
  username = 'foobar'
  password = 'secretpass'

  Given %{I have one user "#{email}" with password "#{password}" and username "#{username}"}
  And %{I go to login}
  And %{I fill in "user_username" with "#{username}"}
  And %{I fill in "user_password" with "#{password}"}
  And %{I press "Login"}
end

Given /^I have one\s+user "([^\"]*)" with password "([^\"]*)" and username "([^\"]*)"$/ do |email, password, username|
  User.delete_all("email = '#{email}'")
  User.new(:email => email,
           :username => username,
           :password => password,
           :password_confirmation => password).save!
end
