class CatalogItemNodePolicy < ApplicationPolicy
  def create?
    moderator_or_admin?
  end

  def destroy?
    moderator_or_admin?
  end

  private

  def moderator_or_admin?
    user&.moderator? || user&.admin?
  end
end
