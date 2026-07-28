class SwitchCatalogItemsTitleSearchToSimple < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    if index_exists?(:catalog_items, nil, name: "index_catalog_items_on_title_tsvector")
      remove_index :catalog_items, name: "index_catalog_items_on_title_tsvector", algorithm: :concurrently
    end
    add_index :catalog_items,
               "to_tsvector('simple', public.immutable_unaccent(title))",
               using: :gin,
               name: "index_catalog_items_on_title_tsvector",
               algorithm: :concurrently
  end

  def down
    remove_index :catalog_items, name: "index_catalog_items_on_title_tsvector", algorithm: :concurrently
    add_index :catalog_items,
               "to_tsvector('french', title)",
               using: :gin,
               name: "index_catalog_items_on_title_tsvector",
               algorithm: :concurrently
  end
end
