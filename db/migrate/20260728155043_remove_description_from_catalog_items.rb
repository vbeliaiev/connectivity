class RemoveDescriptionFromCatalogItems < ActiveRecord::Migration[7.1]
  def change
    remove_column :catalog_items, :description, :text
  end
end
