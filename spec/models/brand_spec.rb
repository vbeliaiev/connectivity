require 'rails_helper'

RSpec.describe Brand, type: :model do
  describe 'associations' do
    it { should have_many(:catalog_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title).with_message('Le nom est obligatoire') }

    it 'rejects a duplicate title, ignoring surrounding spaces' do
      create(:brand, title: 'Peugeot Frères')

      expect(build(:brand, title: '  Peugeot Frères ')).not_to be_valid
    end
  end

  describe '#destroy' do
    it 'refuses to delete a brand used by catalog items' do
      item = create(:catalog_item)

      expect(item.brand.destroy).to be(false)
      expect(item.brand.errors[:base].first).to include('élément(s) du catalogue')
    end

    it 'deletes an unused brand' do
      brand = create(:brand)

      expect { brand.destroy }.to change(described_class, :count).by(-1)
    end
  end
end
