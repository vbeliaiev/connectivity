class RenameNoteTypeToTypeInNodes < ActiveRecord::Migration[7.1]
  def change
    rename_column :nodes, :note_type, :type
  end
end
