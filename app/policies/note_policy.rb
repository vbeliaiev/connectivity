class NotePolicy < ApplicationPolicy
  def index?
    true
  end

  def update?
    # Check if user is owner of the note
    if user.notes.include?(record)
      return true
    end

    # Check if the user is a part of organisation and has sufficient permissions.
    note_organisation = record.organisation
    org_user = user.organisations_users.find_by(organisation_id: note_organisation.id)

    return false unless org_user.present?
    return false if org_user.member?

    org_user.moderator? || org_user.admin? || org_user.owner?
  end

  def destroy?
    update?
  end

  def create?
    org_user = user.organisations_users.find_by(organisation_id: user.current_organisation.id)
    org_user.present?
  end


  def show?
    return true if record.public_visibility?
    user.organisations_users.where(organisation_id: record.organisation.id).any?
  end



  class Scope
    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      return scope.public_visibility unless user

      joined_scope = scope.joins(:organisation).joins('LEFT JOIN organisations_users ON organisations.id = organisations_users.organisation_id')
      joined_scope.where(organisations_users: { user_id: user.id }).or(scope.public_visibility)
    end

    private

    attr_reader :user, :scope
  end
end