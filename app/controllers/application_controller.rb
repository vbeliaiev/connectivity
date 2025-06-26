class ApplicationController < ActionController::Base
  # Devise: Redirect to root after login, logout, sign up, and password reset
  def after_sign_in_path_for(resource)
    root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def after_sign_up_path_for(resource)
    root_path
  end

  def after_resetting_password_path_for(resource)
    root_path
  end
end
