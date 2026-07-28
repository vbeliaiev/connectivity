class CreateCatalogItems < ActiveRecord::Migration[7.1]
  def change
    create_table :catalog_items do |t|
      t.string :title, null: false
      t.references :brand, null: false, foreign_key: true
      t.string :model
      t.references :country, foreign_key: true
      t.integer :production_start_year
      t.integer :production_end_year
      t.text :description

      t.timestamps
    end
  end
end
