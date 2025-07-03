require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:organisations_users).dependent(:destroy) }
  it { should have_many(:organisations).through(:organisations_users) }

  context 'with pre-built user' do
    subject { create(:user) }
    it { should belong_to(:current_organisation).class_name('Organisation').optional }
  end

  describe 'after_create :ensure_personal_organisation' do
    let(:user) { create(:user) }

    it 'creates a personal organisation and sets it as current_organisation' do
      expect(user.current_organisation).to be_present
      expect(user.organisations).to include(user.current_organisation)
      expect(user.organisations_users.find_by(organisation: user.current_organisation).role).to eq('admin')
    end
  end
end
