class Note < ApplicationRecord
  before_save :generate_embedding

  scope :semantic_search, ->(query_embedding, top: 5) {
    order(Arel.sql("embedding <#> '[#{query_embedding.join(',')}]'")).limit(top)
  }

  private

  def generate_embedding
    self.embedding = EmbeddingGenerator.generate(content)
  end

end
