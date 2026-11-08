# A catalog item's category becomes optional so it can be removed from the
# edit form (item_subcategory_id was already optional).
class MakeCatalogItemCategoryOptional < ActiveRecord::Migration[7.1]
  def up
    change_column_null :catalog_items, :item_category_id, true
  end

  # Going back to NOT NULL needs every item to have a category, so items
  # left without one are filed under the "Non catégorisé" default category
  # (the one created by AddItemCategoryToCatalogItems).
  def down
    default_category_id = select_value(<<~SQL.squish)
      INSERT INTO item_categories (name, created_at, updated_at)
      VALUES ('Non catégorisé', NOW(), NOW())
      ON CONFLICT (name) WHERE parent_id IS NULL DO UPDATE SET updated_at = item_categories.updated_at
      RETURNING id
    SQL

    execute("UPDATE catalog_items SET item_category_id = #{Integer(default_category_id)} WHERE item_category_id IS NULL")
    change_column_null :catalog_items, :item_category_id, false
  end
end
