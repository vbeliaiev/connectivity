class Users::RegistrationsController < Devise::RegistrationsController
  layout 'auth'

  before_action :check_privacy_policy, only: [:create]

  protected

  def account_update_params
    params.require(:user).permit(:display_name, :current_password, :password, :password_confirmation)
  end

  private

  def check_privacy_policy
    return if params[:privacy_policy] == '1'
    set_flash_message! :alert, :"You must accept the Privacy Policy to register."
    redirect_to new_user_registration_path and return
  end
end