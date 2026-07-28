class User < ApplicationRecord
  enum :role, { member: 0, moderator: 1, admin: 2 }, default: :member

  has_many :folders
  has_many :notes
  has_many :nodes # node == note || folder

  before_save :set_display_name, if: -> { display_name.blank? }

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable


  private

  def set_display_name
    self.display_name = email.split('@').first
  end
end
