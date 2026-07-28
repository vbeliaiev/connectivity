class CreateBrands < ActiveRecord::Migration[7.1]
  def change
    create_table :brands do |t|
      t.string :title, null: false

      t.timestamps
    end
    add_index :brands, :title, unique: true
  end
end
