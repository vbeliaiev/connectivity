class Article < Node
  has_rich_text :page
  validates :page, presence: true
  validates :title, presence: true
  belongs_to :organisation

  MAX_ITEMS_COUNT = 15

  before_save :sync_content_for_search

  private

  # Keeps the generic `content` column (used by Node#content_search FTS) in
  # sync with the rich text page body as plain text.
  def sync_content_for_search
    self.content = page.body.to_plain_text
  end
end
