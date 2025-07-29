class UserPolicy < ApplicationPolicy
  def set_current_organisation?(organisation_id)
    return false unless user
    user.organisations.pluck(:id).include?(organisation_id.to_i)
  end
end