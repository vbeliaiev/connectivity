class NodePolicy < ApplicationPolicy
  def index?
    return true if !user && record.public_visibility?
    return false unless user

    true
  end

  def show?
    return true if !user && record.public_visibility?
    return false unless user

    true
  end

  def new?
    moderator_or_admin?
  end

  def create?
    moderator_or_admin?
  end

  def edit?
    moderator_or_admin?
  end

  def update?
    moderator_or_admin?
  end

  def destroy?
    moderator_or_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user
        scope.all
      else
        scope.where(visibility_level: :public_visibility)
      end
    end
  end

  private

  def moderator_or_admin?
    user&.moderator? || user&.admin?
  end
end
