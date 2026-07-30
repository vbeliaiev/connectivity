class Brand < ApplicationRecord
  has_many :catalog_items
  has_many :departments

  validates :title, presence: true
end
