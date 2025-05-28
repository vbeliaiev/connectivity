class RenameNotesToNodes < ActiveRecord::Migration[7.1]
  def change
    rename_table :notes, :nodes
  end
end
