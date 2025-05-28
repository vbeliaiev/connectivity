class AddParentIdToNodes < ActiveRecord::Migration[7.1]
  def change
    add_reference :nodes, :parent
  end
end
