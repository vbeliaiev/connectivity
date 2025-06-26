class CreateOrganisationsUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :organisations_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :organisation, null: false, foreign_key: true
      t.integer :role, null: false, default: 0
      t.timestamps
    end
    add_index :organisations_users, [:user_id, :organisation_id], unique: true
  end
end
