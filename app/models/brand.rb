class Brand < ApplicationRecord
  has_many :catalog_items

  validates :title, presence: true
end
