class Folder < Node
  belongs_to :organisation
  belongs_to :author, class_name: 'User', foreign_key: :user_id
  validates :title, presence: true

  MAX_ITEMS_COUNT = 15

  def child_folders(page)
    children.folders.ordered.page(page).per(MAX_ITEMS_COUNT)
  end

  def child_notes(page)
    children.notes.ordered.includes(:rich_text_page).page(page).per(Note::MAX_ITEMS_COUNT)
  end
end
