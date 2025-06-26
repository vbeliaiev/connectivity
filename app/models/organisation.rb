class Organisation < ApplicationRecord
  has_many :organisations_users, dependent: :destroy
  has_many :users, through: :organisations_users

  validates :name, presence: true, uniqueness: true
end
