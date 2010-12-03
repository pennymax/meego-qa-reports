class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :recoverable, :lockable, and :timeoutable
  devise :database_authenticatable, :rememberable, :trackable, :registerable, :validatable, :token_authenticatable

  validates_uniqueness_of :email
  validates_presence_of :name

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :password, :email, :password_confirmation, :remember_me, :authentication_token
end

