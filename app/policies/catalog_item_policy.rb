class CatalogItemPolicy < ApplicationPolicy
  # CatalogItemsController requires authentication for every action, so any
  # signed-in user may view a catalog item.
  def show?
    user.present?
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

  private

  def moderator_or_admin?
    user&.moderator? || user&.admin?
  end
end
