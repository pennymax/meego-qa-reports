class Users::SessionsController < Devise::SessionsController
  before_filter :save_path, :only => :new

  private

  def save_path
    session[:return_to] = request.referrer
  end

  def after_sign_in_path_for(resource)
    session[:return_to].nil? ? '/' : session[:return_to]
  end
end
