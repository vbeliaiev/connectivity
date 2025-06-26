class AddUserToNode < ActiveRecord::Migration[7.1]
  def change
    add_reference :nodes, :user, foreign_key: true, null: false
  end
end
