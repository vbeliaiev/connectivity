class AddCurrentOrganisationToUsers < ActiveRecord::Migration[7.1]
  def change

    add_reference :users, :current_organisation
  end
end
