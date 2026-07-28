class Users::RegistrationsController < Devise::RegistrationsController
  layout 'auth'

  protected

  def account_update_params
    params.require(:user).permit(:display_name, :current_password, :password, :password_confirmation)
  end

  # Devise's default update_resource always requires current_password,
  # even when the user isn't changing their password. Only require it
  # when a new password is actually being submitted.
  def update_resource(resource, params)
    if params[:password].blank?
      resource.update_without_password(params.except(:current_password, :password, :password_confirmation))
    else
      resource.update_with_password(params)
    end
  end

  def after_update_path_for(resource)
    edit_user_registration_path
  end
end
