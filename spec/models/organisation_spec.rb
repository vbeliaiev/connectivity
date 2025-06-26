require 'rails_helper'

RSpec.describe Organisation, type: :model do
  it { should have_many(:organisations_users).dependent(:destroy) }
  it { should have_many(:users).through(:organisations_users) }
  it { should validate_presence_of(:name) }

  context 'validate uniqueness' do
    subject { create(:organisation) }
    it { should validate_uniqueness_of(:name) }
  end
end
