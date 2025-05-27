class AddEmbeddingToNotes < ActiveRecord::Migration[7.1]
  def change

    add_column :notes, :embedding, :vector, limit: 1536
  end
end
