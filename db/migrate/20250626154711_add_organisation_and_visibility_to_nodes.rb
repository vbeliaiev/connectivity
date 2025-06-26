class AddOrganisationAndVisibilityToNodes < ActiveRecord::Migration[7.1]
  def change
    add_reference :nodes, :organisation, null: false, foreign_key: true
    add_column :nodes, :visibility_level, :integer, null: false, default: 0
  end
end
