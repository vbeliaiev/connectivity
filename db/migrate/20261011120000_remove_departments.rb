class RemoveDepartments < ActiveRecord::Migration[7.1]
  def up
    remove_reference :catalog_items, :department, foreign_key: true, index: true
    drop_table :departments
  end

  def down
    create_table :departments do |t|
      t.string :name, null: false
      t.references :brand, null: false, foreign_key: true

      t.timestamps
    end
    add_index :departments, [:brand_id, :name], unique: true

    add_reference :catalog_items, :department, foreign_key: true
  end
end
