class CreateCatalogItemNodes < ActiveRecord::Migration[7.1]
  def change
    create_table :catalog_item_nodes do |t|
      t.references :node, null: false, foreign_key: true
      t.references :catalog_item, null: false, foreign_key: true

      t.timestamps
    end
    add_index :catalog_item_nodes, [:node_id, :catalog_item_id], unique: true
  end
end
