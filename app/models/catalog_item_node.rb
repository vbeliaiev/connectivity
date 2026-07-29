class CatalogItemNode < ApplicationRecord
  belongs_to :node
  belongs_to :catalog_item

  validates :catalog_item_id, uniqueness: { scope: :node_id, message: "est déjà associé à ce contenu" }
end
