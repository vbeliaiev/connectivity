class Note < Node
  has_rich_text :page
  validates :page, presence: true
  validates :title, presence: true
  belongs_to :organisation

  MAX_ITEMS_COUNT = 15

  before_save :generate_embedding, unless: -> { Rails.env.test? || Rails.env.development? }
  before_save :sync_content_for_search

  scope :semantic_search, ->(query_embedding, top: 5) {
    order(Arel.sql("embedding <#> '[#{query_embedding.join(',')}]'")).limit(top)
  }

  private

  def generate_embedding
    plain_text = page.body.to_plain_text
    self.embedding = EmbeddingGenerator.generate(plain_text)
  end

  # Keeps the generic `content` column (used by Node#content_search FTS) in
  # sync with the rich text page body as plain text.
  def sync_content_for_search
    self.content = page.body.to_plain_text
  end
end
