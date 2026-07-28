class UsersController < ApplicationController
  after_action :verify_pundit_authorization

  USERS_ITEMS_MAX_COUNT = 15

  before_action :set_user, only: %i[ edit update destroy ]

  def index
    authorize User
    @users = policy_scope(User).order(created_at: :desc).page(params[:users_page]).per(USERS_ITEMS_MAX_COUNT)
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      redirect_to users_path, notice: "L'adhérent a été créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    if @user.update(update_params)
      redirect_to users_path, notice: "L'adhérent a été mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user

    if @user.destroy!
      redirect_to users_path, notice: "L'adhérent a été supprimé avec succès."
    else
      redirect_to users_path, alert: "L'adhérent n'a pas pu être supprimé. Veuillez réessayer et prévenir l'administrateur."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :display_name, :role, :password, :password_confirmation)
  end

  # On update, the password fields are optional: if left blank, the
  # current password is kept unchanged instead of being wiped out.
  def update_params
    permitted = user_params
    permitted = permitted.except(:password, :password_confirmation) if permitted[:password].blank?
    permitted
  end
end
