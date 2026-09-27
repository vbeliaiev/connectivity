class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :set_locale
  before_action :set_sidebar_folders

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

  # Rails calls this directly when generating URLs (via *_path/*_url helpers,
  # including inside Devise's own controllers), so it must not be private.
  def default_url_options
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
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

  # Resolves the active locale from the routing-provided `:locale` param
  # (only ever "en" or absent/nil, per the `locale: /en/` route constraint)
  # falling back to the app's default locale (fr).
  def set_locale
    I18n.locale = params[:locale].presence || I18n.default_locale
  end

  # Loads the folder tree shown in the left sidebar on every page (folder,
  # article, pdf, video, and gallery show pages, plus the root articles
  # index). Runs for signed-out visitors too: FolderPolicy::Scope resolves
  # to public folders only when there is no current_user, so anonymous
  # users see the public folder tree instead of an empty sidebar.
  def set_sidebar_folders
    @sidebar_folders = FolderPolicy::Scope.new(current_user, Folder.all)
      .resolve.root_records.ordered
      .page(params[:folders_page]).per(10)
  end
end
