require 'rails_helper'

RSpec.describe Country, type: :model do
  describe 'associations' do
    it { should have_many(:catalog_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name).with_message('Le nom est obligatoire') }

    it 'rejects a duplicate name, ignoring surrounding spaces' do
      create(:country, name: 'France')

      expect(build(:country, name: ' France  ')).not_to be_valid
    end
  end

  describe '#destroy' do
    it 'refuses to delete a country used by catalog items' do
      item = create(:catalog_item)

      expect(item.country.destroy).to be(false)
      expect(item.country.errors[:base].first).to include('élément(s) du catalogue')
    end

    it 'deletes an unused country' do
      country = create(:country)

      expect { country.destroy }.to change(described_class, :count).by(-1)
    end
  end
end
