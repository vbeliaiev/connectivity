class NodePolicy < ApplicationPolicy
  def index?
    true
  end

  def update?
    return false unless user
    # Check if user is owner of the note
    if user.nodes.include?(record)
      return true
    end

    # Check if the user is a part of organisation and has sufficient permissions.
    node_organisation = record.organisation
    org_user = user.organisations_users.find_by(organisation_id: node_organisation.id)

    return false unless org_user.present?
    return false if org_user.member?

    org_user.moderator? || org_user.admin? || org_user.owner?
  end

  def destroy?
    return false unless user
    update?
  end

  def create?
    return false unless user
    org_user = user.organisations_users.find_by(organisation_id: user.current_organisation_id)
    return false unless org_user.present?

    return true if record.parent.blank?

    record.parent.organisation_id == user.current_organisation_id
  end


  def show?
    return true if record.public_visibility?
    return false unless user
    user.organisations_users.where(organisation_id: record.organisation.id).any?
  end



  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      return scope.public_visibility unless user

      scope.joins(:organisation).where(organisation: { id: user.current_organisation_id })
    end

    private

    attr_reader :user, :scope
  end
end