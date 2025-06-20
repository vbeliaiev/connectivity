class Note < Node
  has_rich_text :page

  before_save :generate_embedding, unless: -> { Rails.env.test? }

  scope :semantic_search, ->(query_embedding, top: 5) {
    order(Arel.sql("embedding <#> '[#{query_embedding.join(',')}]'")).limit(top)
  }

  private

  def generate_embedding
    content = page.body.to_plain_text
    self.embedding = EmbeddingGenerator.generate(content)
  end
end
