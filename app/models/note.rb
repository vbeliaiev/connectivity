class Note < ApplicationRecord
  has_rich_text :page

  enum note_type: {
    page: 'page'
  }

  before_save :generate_embedding
  before_save :set_note_type


  scope :semantic_search, ->(query_embedding, top: 5) {
    order(Arel.sql("embedding <#> '[#{query_embedding.join(',')}]'")).limit(top)
  }

  private

  def generate_embedding
    content = page.body.to_plain_text
    self.embedding = EmbeddingGenerator.generate(content)
  end

  def set_note_type
    self.note_type ||= 'page'
  end
end
