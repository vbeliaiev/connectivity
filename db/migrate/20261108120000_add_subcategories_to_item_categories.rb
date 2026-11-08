# Two-level category tree: a category with a parent_id is a subcategory of
# that parent. Catalog items keep pointing at their top-level category
# through item_category_id and may additionally point at one subcategory of
# it through item_subcategory_id.
class AddSubcategoriesToItemCategories < ActiveRecord::Migration[7.1]
  def change
    add_reference :item_categories, :parent, foreign_key: { to_table: :item_categories }

    # Names used to be globally unique. Subcategory names only need to be
    # unique within their parent (e.g. "Moulin avec trémie extérieure" can
    # exist under both "Bois" and "Fonte"), and top-level names stay unique
    # among themselves. Two partial indexes because PostgreSQL treats NULLs
    # as distinct in a plain (parent_id, name) unique index.
    remove_index :item_categories, :name, unique: true
    add_index :item_categories, :name, unique: true, where: 'parent_id IS NULL',
                                       name: 'index_item_categories_on_name_for_roots'
    add_index :item_categories, %i[parent_id name], unique: true, where: 'parent_id IS NOT NULL',
                                                    name: 'index_item_categories_on_parent_id_and_name'

    add_reference :catalog_items, :item_subcategory, foreign_key: { to_table: :item_categories }
  end
end
