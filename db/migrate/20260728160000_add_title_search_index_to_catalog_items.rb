class AddTitleSearchIndexToCatalogItems < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :catalog_items,
               "to_tsvector('french', title)",
               using: :gin,
               name: "index_catalog_items_on_title_tsvector",
               algorithm: :concurrently
  end
end
