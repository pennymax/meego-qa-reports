class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :registerable, :recoverable, :lockable, :validatable and :timeoutable
  devise :database_authenticatable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :username, :password, :email, :password_confirmation, :remember_me
end
