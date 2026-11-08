# Countries are managed from the admin-only settings area (Settings >
# Pays); the catalog item form only picks from the existing list.
class Country < ApplicationRecord
  MAX_NAME_LENGTH = 180

  has_many :catalog_items

  normalizes :name, with: ->(name) { name.strip }

  # The app has no French Active Record translations, so messages are
  # spelled out here and shown as-is in the settings views.
  validates :name, presence: { message: 'Le nom est obligatoire' },
                   length: { maximum: MAX_NAME_LENGTH, message: "Le nom ne doit pas dépasser #{MAX_NAME_LENGTH} caractères" },
                   uniqueness: { message: 'Ce pays existe déjà' }

  # catalog_items.country_id has a foreign key, so a country still in use
  # can't go away; refuse with a message the settings page can show.
  before_destroy :ensure_not_in_use

  private

  def ensure_not_in_use
    count = catalog_items.count
    return if count.zero?

    errors.add(:base, "Impossible de supprimer « #{name} » : #{count} élément(s) du catalogue l'utilisent.")
    throw :abort
  end
end
