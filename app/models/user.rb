class User < ApplicationRecord
  before_save :set_display_name, if: -> { display_name.blank? }
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  private

  def set_display_name
    self.display_name = email.split('@').first
  end
end
