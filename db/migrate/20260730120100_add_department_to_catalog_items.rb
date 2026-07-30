class AddDepartmentToCatalogItems < ActiveRecord::Migration[7.1]
  def change
    add_reference :catalog_items, :department, foreign_key: true
  end
end
