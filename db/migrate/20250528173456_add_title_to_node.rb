class AddTitleToNode < ActiveRecord::Migration[7.1]
  def change
    add_column :nodes, :title, :string
  end
end
