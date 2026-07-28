class CatalogItemNode < ApplicationRecord
  belongs_to :node
  belongs_to :catalog_item
end
