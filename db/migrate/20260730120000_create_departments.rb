class CreateDepartments < ActiveRecord::Migration[7.1]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.references :brand, null: false, foreign_key: true

      t.timestamps
    end
    add_index :departments, [:brand_id, :name], unique: true
  end
end
