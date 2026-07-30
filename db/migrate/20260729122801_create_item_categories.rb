class CreateItemCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :item_categories do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :item_categories, :name, unique: true
  end
end
