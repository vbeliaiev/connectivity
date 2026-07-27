require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'role' do
    it 'defaults to member' do
      user = build(:user)
      expect(user.role).to eq('member')
    end

    it 'can be set to moderator' do
      user = build(:user, role: :moderator)
      expect(user.moderator?).to be true
    end

    it 'can be set to admin' do
      user = build(:user, role: :admin)
      expect(user.admin?).to be true
    end
  end
end
