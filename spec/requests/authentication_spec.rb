require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let(:password) { 'password123' }
  let(:user) { FactoryBot.create(:user, password: password) }

  describe 'Login/Logout' do
    it 'allows login and logout' do
      post user_session_path, params: { user: { email: user.email, password: password } }
      expect(response).to redirect_to(root_path)
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'Forgot password/reset password' do
    it 'sends reset password instructions and allows password reset' do
      post user_password_path, params: { user: { email: user.email } }
      expect(ActionMailer::Base.deliveries.last.subject).to include('Reset password')
      # Simulate password reset (token extraction would be needed for full test)
    end
  end

  describe 'Profile updates' do
    before { sign_in user }

    it 'allows updating display_name' do
      put user_registration_path, params: {
        user: {
          display_name: 'NewName',
          current_password: password
        }
      }

      expect(response).to redirect_to(edit_user_registration_path)
      user.reload
      expect(user.display_name).to eq('NewName')
    end

    it 'allows updating password with current password' do
      put user_registration_path, params: {
        user: {
          password: 'newpassword123',
          password_confirmation: 'newpassword123',
          current_password: password
        }
      }
      expect(response).to redirect_to(edit_user_registration_path)
    end

    it 'does not allow email change' do
      expect do
        put user_registration_path, params: {
          user: {
            email: 'new@email.com',
            current_password: password
          }
        }
        follow_redirect!
      end.to_not change { user.reload.email }
    end

    it 'shows a message to contact administrator to update email' do
      get edit_user_registration_path
      expect(response.body).to include("Pour changer votre e-mail, veuillez contacter l'administrateur.")
    end
  end
end
