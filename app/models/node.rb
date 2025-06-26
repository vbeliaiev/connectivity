class Node < ApplicationRecord
  has_many :children, class_name: 'Node', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Node', optional: true
  belongs_to :author, class_name: 'User', foreign_key: :user_id

  enum visibility_level: { internal: 0, public_visibility: 1 }

  scope :folders, -> { where(type: 'Folder') }
  scope :notes, -> { where(type: 'Note') }
  scope :ordered, -> { order(Arel.sql('position ASC NULLS LAST'), created_at: :desc) }

  GENERIC_FOLDER_NAME = 'Generic'.freeze

  def self.generic_folder_for(user_id, organisation_id: nil)
    organisation_id ||= User.find(user_id).personal_organisation.id
    find_or_create_by(title: GENERIC_FOLDER_NAME, position: -999, user_id: user_id, organisation_id: organisation_id)
  end

  def generic?
    title == GENERIC_FOLDER_NAME
  end
end
