require 'rails_helper'

RSpec.describe Organisation, type: :model do
  it { should have_many(:organisations_users).dependent(:destroy) }
  it { should have_many(:users).through(:organisations_users) }
  it { should validate_presence_of(:name) }

  context 'validate uniqueness' do
    subject { create(:organisation) }
    it { should validate_uniqueness_of(:name) }
  end

  describe '.fetch_personal_organisation_for' do
    let!(:user) { create(:user) }

    # After user create it creates a default personal organisation, so need to clean it.
    # Do not use destroy_all because it destroys only relationships not the organisation.
    before { user.organisations.map(&:destroy) }

    it "returns nil when personal organisation doesn't exist" do
      org = described_class.fetch_personal_organisation_for(user.id)
      expect(org).to be(nil)
    end

    context "when personal organisation exists" do
      let(:personal_organisation) { described_class.create(name: "#{user.email.split('@').first}-org", personal: true) }

      before do
        OrganisationsUser.create(organisation: personal_organisation, user: user, role: OrganisationsUser.roles[:admin])
      end

      it 'returns personal organisation' do
        org = described_class.fetch_personal_organisation_for(user.id)
        expect(org).to eq(personal_organisation)
      end
    end
  end

  describe '.create_default_personal_organisation' do
    let(:email) { 'vladyslav@gmail.com' }

    it 'creates a personal organisation based on user email' do
      org = described_class.create_default_personal_organisation(email)

      expect(org.name).to eq('vladyslav-org')
      expect(org.personal).to be(true)
    end
  end
end
