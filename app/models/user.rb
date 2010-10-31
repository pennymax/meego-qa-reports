class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :recoverable, :lockable, and :timeoutable
  devise :database_authenticatable, :rememberable, :trackable, :registerable, :validatable

  validates_uniqueness_of :email
  validates_presence_of :name

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :password, :email, :password_confirmation, :remember_me
end

