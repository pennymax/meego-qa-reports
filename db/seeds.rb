# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

if Rails.env == "development":
  user_email = 'test@leonidasoy.fi'
  existing_user = User.find_by_email(user_email)
  existing_user.delete if existing_user
  User.create! :password => 'testpass', :email => user_email, :name => "Jean-Claude Van Damme"
end

