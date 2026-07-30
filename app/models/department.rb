class Department < ApplicationRecord
  belongs_to :brand
  has_many :catalog_items

  validates :name, presence: true, uniqueness: { scope: :brand_id }
end
