class AddItemCategoryToCatalogItems < ActiveRecord::Migration[7.1]
  def up
    add_reference :catalog_items, :item_category, foreign_key: true

    default_category_id = execute(
      "INSERT INTO item_categories (name, created_at, updated_at) VALUES ('Non catégorisé', NOW(), NOW()) RETURNING id"
    ).first['id']

    execute("UPDATE catalog_items SET item_category_id = #{default_category_id} WHERE item_category_id IS NULL")

    change_column_null :catalog_items, :item_category_id, false
  end

  def down
    remove_reference :catalog_items, :item_category, foreign_key: true
  end
end
