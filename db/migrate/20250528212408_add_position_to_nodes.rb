class AddPositionToNodes < ActiveRecord::Migration[7.1]
  def change
    add_column :nodes, :position, :integer
  end
end
