# Categories form a two-level tree: top-level categories (parent_id NULL,
# e.g. "Bois") and their subcategories (e.g. "Moulin avec trémie
# extérieure"). A catalog item belongs to one top-level category and may
# also belong to one subcategory of it (see CatalogItem#item_subcategory).
class ItemCategory < ApplicationRecord
  MAX_NAME_LENGTH = 180

  belongs_to :parent, class_name: 'ItemCategory', optional: true, inverse_of: :subcategories
  has_many :subcategories, -> { order(:name) }, class_name: 'ItemCategory', foreign_key: :parent_id,
                                                inverse_of: :parent
  has_many :catalog_items
  has_many :subcategorized_catalog_items, class_name: 'CatalogItem', foreign_key: :item_subcategory_id,
                                          inverse_of: :item_subcategory

  scope :roots, -> { where(parent_id: nil) }

  normalizes :name, with: ->(name) { name.strip }

  # The app has no French Active Record translations, so messages are
  # spelled out here and shown as-is (without the attribute name) in the
  # settings views.
  validates :name, presence: { message: 'Le nom est obligatoire' },
                   length: { maximum: MAX_NAME_LENGTH, message: "Le nom ne doit pas dépasser #{MAX_NAME_LENGTH} caractères" },
                   uniqueness: { scope: :parent_id, message: 'Ce nom existe déjà à ce niveau' }
  validate :parent_is_a_root_category

  # Deleting a category that is still in use would either fail on the
  # foreign keys or silently orphan catalog items, so it's refused with a
  # message the settings page can show.
  before_destroy :ensure_not_in_use

  def root?
    parent_id.nil?
  end

  # Number of catalog items filed under this category (top-level) or this
  # subcategory, whichever this record is.
  def catalog_items_count
    root? ? catalog_items.count : subcategorized_catalog_items.count
  end

  private

  def parent_is_a_root_category
    return if parent.nil?

    if parent == self || !parent.root?
      errors.add(:parent, 'Une sous-catégorie ne peut être rattachée qu’à une catégorie principale')
    elsif persisted? && subcategories.exists?
      errors.add(:parent, 'Une catégorie qui a des sous-catégories ne peut pas devenir une sous-catégorie')
    end
  end

  def ensure_not_in_use
    if subcategories.exists?
      errors.add(:base, "Impossible de supprimer « #{name} » : supprimez d'abord ses sous-catégories.")
    end

    count = catalog_items_count
    if count.positive?
      errors.add(:base, "Impossible de supprimer « #{name} » : #{count} élément(s) du catalogue l'utilisent.")
    end

    throw :abort if errors.any?
  end
end
