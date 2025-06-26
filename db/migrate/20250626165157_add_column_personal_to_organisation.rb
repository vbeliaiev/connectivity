class AddColumnPersonalToOrganisation < ActiveRecord::Migration[7.1]
  def change
    add_column :organisations, :personal, :boolean, default: false
  end
end
