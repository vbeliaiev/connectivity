class CreateGalleryItems < ActiveRecord::Migration[7.1]
  def change
    create_table :gallery_items do |t|
      # Polymorphic owner so this table can be reused for future collection
      # types (e.g. video playlists), not just photo galleries.
      t.string :gallery_type, null: false
      t.bigint :gallery_id, null: false

      t.text :description
      t.boolean :cover, null: false, default: false
      t.integer :position

      t.timestamps
    end

    add_index :gallery_items, [:gallery_type, :gallery_id]
    add_index :gallery_items, [:gallery_type, :gallery_id, :cover]
  end
end
