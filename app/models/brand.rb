# Brands are managed from the admin-only settings area (Settings >
# Marques); the catalog item form only picks from the existing list.
class Brand < ApplicationRecord
  MAX_TITLE_LENGTH = 180

  has_many :catalog_items

  normalizes :title, with: ->(title) { title.strip }

  # The app has no French Active Record translations, so messages are
  # spelled out here and shown as-is in the settings views.
  validates :title, presence: { message: 'Le nom est obligatoire' },
                    length: { maximum: MAX_TITLE_LENGTH, message: "Le nom ne doit pas dépasser #{MAX_TITLE_LENGTH} caractères" },
                    uniqueness: { message: 'Cette marque existe déjà' }

  # catalog_items.brand_id is NOT NULL, so a brand still in use can't go
  # away; refuse with a message the settings page can show.
  before_destroy :ensure_not_in_use

  private

  def ensure_not_in_use
    count = catalog_items.count
    return if count.zero?

    errors.add(:base, "Impossible de supprimer « #{title} » : #{count} élément(s) du catalogue l'utilisent.")
    throw :abort
  end
end
