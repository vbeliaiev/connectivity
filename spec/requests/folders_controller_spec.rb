require 'rails_helper'

RSpec.describe FoldersController, type: :request do
  let(:current_user) { create(:user, :moderator) }

  before do
    current_user.confirm
    sign_in current_user
  end

  describe 'GET /folders/:id' do
    let!(:folder) { create(:folder, visibility_level: :public_visibility) }

    it 'returns a successful response and displays the folder title' do
      get folder_path(folder)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(folder.title)
    end
  end

  describe 'GET /folders/new' do
    it 'returns a successful response and displays the folder creation title' do
      get new_folder_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Création d'un dossier")
    end
  end

  describe 'POST /folders' do
    let(:folder_title) { FFaker::Lorem.word }
    let(:valid_params) do
      {
        folder: {
          title: folder_title
        }
      }
    end

    it 'creates a folder and displays its title' do
      post folders_path, params: valid_params
      folder = Folder.order(:created_at).last
      expect(response).to redirect_to(folder_path(folder))
      follow_redirect!
      expect(response.body).to include(folder.title)
    end
  end

  describe 'PATCH /folders/:id' do
    let!(:folder) { create(:folder, author: current_user) }
    let(:new_title) { FFaker::Lorem.word }
    let(:update_params) do
      {
        folder: {
          title: new_title
        }
      }
    end

    it 'updates the folder and displays the new title' do
      patch folder_path(folder), params: update_params
      expect(response).to redirect_to(folder_path(folder))
      follow_redirect!
      folder.reload
      expect(response.body).to include(folder.title)
    end
  end

  describe 'DELETE /folders/:id' do
    let!(:folder) { create(:folder, title: DateTime.current.to_i.to_s, author: current_user) }

    it 'destroys the folder and redirects to index, folder title is not present' do
      delete folder_path(folder)
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(Folder.exists?(folder.id)).to be_falsey
      expect(response.body).not_to include(folder.title)
    end
  end

  # TODO: check user permissions for each action below.
  # Each example should verify that the correct role (member / moderator / admin / guest)
  # is allowed or denied access, and that the response matches the expected behaviour.
  context 'authorization' do
    it 'allows a guest to view a public folder' do
      skip 'user permission checks not yet implemented'
    end

    it 'denies a guest access to an internal folder' do
      skip 'user permission checks not yet implemented'
    end

    it 'denies a member from creating a folder' do
      skip 'user permission checks not yet implemented'
    end

    it 'denies a member from updating a folder' do
      skip 'user permission checks not yet implemented'
    end

    it 'denies a member from deleting a folder' do
      skip 'user permission checks not yet implemented'
    end

    it 'allows a moderator to create a folder' do
      skip 'user permission checks not yet implemented'
    end

    it 'allows an admin to destroy a folder' do
      skip 'user permission checks not yet implemented'
    end
  end
end
