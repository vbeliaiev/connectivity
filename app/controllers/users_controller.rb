class UsersController < ApplicationController
  def set_current_organisation
    unless UserPolicy.new(current_user, nil).set_current_organisation?(params[:organisation_id])
       raise Pundit::NotAuthorizedError, "not authorized"
    end

     current_user.update(current_organisation_id: params[:organisation_id])
     redirect_back fallback_location: root_path, notice: "Current Organisation changed"
  end
end