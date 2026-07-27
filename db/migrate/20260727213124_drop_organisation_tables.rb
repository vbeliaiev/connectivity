class DropOrganisationTables < ActiveRecord::Migration[7.1]
  def up
    remove_reference :nodes, :organisation, foreign_key: true
    remove_reference :users, :current_organisation

    drop_table :organisations_users
    drop_table :organisations
  end

  def down
    create_table :organisations do |t|
      t.string :name, null: false
      t.timestamps
      t.boolean :personal, default: false
    end
    add_index :organisations, :name, unique: true

    create_table :organisations_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organisation, null: false, foreign_key: true
      t.integer :role, null: false, default: 0
      t.timestamps
    end
    add_index :organisations_users, [:user_id, :organisation_id], unique: true

    add_reference :nodes, :organisation, null: false, foreign_key: true
    add_reference :users, :current_organisation
  end
end
