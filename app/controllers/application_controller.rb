class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :set_sidebar_folders, if: :user_signed_in?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
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

  protected

  def verify_pundit_authorization
    if action_name == "index"
      verify_policy_scoped
    else
      verify_authorized
    end
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(root_path)
  end

  private

  # Loads the folder tree shown in the left sidebar on every page (folder,
  # note, pdf, video, and gallery show pages, plus the root notes index).
  def set_sidebar_folders
    @sidebar_folders = FolderPolicy::Scope.new(current_user, Folder.all)
      .resolve.root_records.ordered
      .page(params[:folders_page]).per(10)
  end
end
