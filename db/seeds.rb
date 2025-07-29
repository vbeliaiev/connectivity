# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


user = User.create(email: 'vladislav.belyaev.93@gmail.com', password: '123123', display_name: 'Vlad')
user.confirm
current_organisation = user.current_organisation
user.update(current_organisation_id: current_organisation.id)

folder1 = FactoryBot.create(:folder, title: 'Documents', author: user)
subfolder1 = FactoryBot.create(:folder, title: 'Top Secret', author: user, parent: folder1)

folder2 = FactoryBot.create(:folder, title: 'Notes', author: user)
subfolder2 = FactoryBot.create(:folder, title: 'Cooking recipes', author: user, parent: folder2)


[folder1, subfolder1, folder2, subfolder2].each do |folder|
  3.times { FactoryBot.create(:note, parent: folder, author: user, page: FFaker::Lorem.paragraph(20)) }
end