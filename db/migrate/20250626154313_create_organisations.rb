class CreateOrganisations < ActiveRecord::Migration[7.1]
  def change
    create_table :organisations do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :organisations, :name, unique: true
  end
end
