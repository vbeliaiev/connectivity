require 'rails_helper'

RSpec.describe VideoNotesController, type: :request do
  let(:current_user) { create(:user, :moderator) }

  before do
    current_user.confirm
    sign_in current_user
  end

  # TODO: check user permissions for each action below.
  # Each example should verify that the correct role (member / moderator / admin / guest)
  # is allowed or denied access, and that the response matches the expected behaviour.
  context 'authorization' do
    it 'allows a guest to view a public video note' do
      skip 'user permission checks not yet implemented'
    end

    it 'denies a guest access to an internal video note' do
      skip 'user permission checks not yet implemented'
    end

    it 'denies a member from creating a video note' do
      skip 'user permission checks not yet implemented'
    end

    it 'denies a member from updating a video note' do
      skip 'user permission checks not yet implemented'
    end

    it 'denies a member from deleting a video note' do
      skip 'user permission checks not yet implemented'
    end

    it 'allows a moderator to create a video note' do
      skip 'user permission checks not yet implemented'
    end

    it 'allows an admin to destroy a video note' do
      skip 'user permission checks not yet implemented'
    end
  end
end
