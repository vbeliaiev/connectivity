require 'rails_helper'

RSpec.describe OrganisationsUser, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:organisation) }

  it { should define_enum_for(:role).with_values(member: 0, moderator: 1, admin: 2) }
  it { should validate_presence_of(:role) }

  context 'validate uniqueness' do
    subject { create(:organisations_user, user: create(:user), organisation: create(:organisation)) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:organisation_id) }
  end


end
