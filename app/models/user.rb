class User < ApplicationRecord
  before_save :set_display_name, if: -> { display_name.blank? }
  after_create :personal_organisation

  has_many :organisations_users, dependent: :destroy
  has_many :organisations, through: :organisations_users
  belongs_to :current_organisation, class_name: 'Organisation', foreign_key: 'current_organisation_id', optional: true
  has_many :folders
  has_many :notes

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable


  def current_organisation
    super || personal_organisation
  end
  def personal_organisation
    personal_organisation = Organisation.joins(:organisations_users).find_by(organisations_users: { user_id: id }, organisations: { personal: true })
    return personal_organisation if personal_organisation
    organisation = Organisation.create!(name: "#{email.split('@').first}-org",personal: true)
    OrganisationsUser.create(organisation: organisation, user: self, role: OrganisationsUser.roles[:admin])
    organisation
  end

  private

  def set_display_name
    self.display_name = email.split('@').first
  end
end
