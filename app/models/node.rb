class Node < ApplicationRecord
  has_many :children, class_name: 'Node', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Node', optional: true

  scope :folders, -> { where(type: 'Folder') }
  scope :notes, -> { where(type: 'Note') }
  scope :ordered, -> { order(Arel.sql('position ASC NULLS LAST'), created_at: :desc) }

  GENERIC_FOLDER_NAME = 'Generic'.freeze

  def self.generic_folder
    find_or_create_by(title: GENERIC_FOLDER_NAME, position: -999)
  end

  def generic?
    title == GENERIC_FOLDER_NAME
  end
end
