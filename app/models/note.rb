class Note < Node
  has_rich_text :page
  validates :page, presence: true
  belongs_to :organisation

  MAX_ITEMS_COUNT = 15

  before_save :generate_embedding, unless: -> { Rails.env.test? || Rails.env.development? }

  scope :semantic_search, ->(query_embedding, top: 5) {
    order(Arel.sql("embedding <#> '[#{query_embedding.join(',')}]'")).limit(top)
  }

  private

  def generate_embedding
    content = page.body.to_plain_text
    self.embedding = EmbeddingGenerator.generate(content)
  end
end
