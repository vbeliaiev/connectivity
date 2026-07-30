class ItemCategory < ApplicationRecord
  has_many :catalog_items

  validates :name, presence: true
end
