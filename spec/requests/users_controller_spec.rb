require 'rails_helper'

RSpec.describe UsersController, type: :request do
  let(:admin) { create(:user, :admin) }

  describe 'as an admin' do
    before { sign_in admin }

    describe 'GET /users' do
      let!(:member) { create(:user) }

      it 'returns a successful response and lists users' do
        get users_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(member.email)
      end
    end

    describe 'GET /users/new' do
      it 'returns a successful response' do
        get new_user_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Création d'un adhérent")
      end
    end

    describe 'POST /users' do
      let(:email) { FFaker::Internet.email }
      let(:valid_params) do
        {
          user: {
            email: email,
            display_name: 'Nouvel Adherent',
            role: 'member',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'creates a user' do
        expect do
          post users_path, params: valid_params
        end.to change(User, :count).by(1)

        expect(response).to redirect_to(users_path)
        user = User.order(:created_at).last
        expect(user.email).to eq(email)
      end

      it 'allows the newly created user to log in immediately' do
        post users_path, params: valid_params
        delete destroy_user_session_path

        post user_session_path, params: { user: { email: email, password: 'password123' } }
        expect(response).to redirect_to(root_path)
      end
    end

    describe 'PATCH /users/:id' do
      let!(:member) { create(:user) }

      it 'updates the user without changing the password when left blank' do
        patch user_path(member), params: { user: { display_name: 'Updated Name' } }
        expect(response).to redirect_to(users_path)
        member.reload
        expect(member.display_name).to eq('Updated Name')
      end

      it 'updates the password when provided' do
        patch user_path(member), params: {
          user: { password: 'newpassword123', password_confirmation: 'newpassword123' }
        }
        expect(response).to redirect_to(users_path)
        member.reload
        expect(member.valid_password?('newpassword123')).to be true
      end
    end

    describe 'DELETE /users/:id' do
      let!(:member) { create(:user) }

      it 'destroys the user' do
        delete user_path(member)
        expect(response).to redirect_to(users_path)
        expect(User.exists?(member.id)).to be_falsey
      end

      it 'does not allow an admin to delete themselves' do
        delete user_path(admin)
        expect(response).to redirect_to(root_path)
        expect(User.exists?(admin.id)).to be_truthy
      end
    end
  end

  context 'authorization' do
    let!(:member_record) { create(:user) }

    it 'denies a member access to the users index' do
      sign_in create(:user)
      get users_path
      expect(response).to redirect_to(root_path)
    end

    it 'denies a moderator access to the users index' do
      sign_in create(:user, :moderator)
      get users_path
      expect(response).to redirect_to(root_path)
    end

    it 'denies a guest access to the users index' do
      get users_path
      expect(response).to redirect_to(root_path)
    end
  end
end
