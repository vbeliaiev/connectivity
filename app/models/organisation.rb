class Organisation < ApplicationRecord
  has_many :organisations_users, dependent: :destroy
  has_many :users, through: :organisations_users

  validates :name, presence: true, uniqueness: true

  def self.fetch_personal_organisation_for(user_id)
    joins(:organisations_users).find_by(organisations_users: { user_id: user_id }, organisations: { personal: true })
  end

  def self.create_default_personal_organisation(email)
    create!(name: "#{email.split('@').first}-org", personal: true)
  end
end
