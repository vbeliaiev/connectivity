class OrganisationsUser < ApplicationRecord
  belongs_to :user
  belongs_to :organisation

  validates :user_id, uniqueness: { scope: :organisation_id }
  validates :role, presence: true
  enum role: { member: 0, moderator: 1, admin: 2 }
end
