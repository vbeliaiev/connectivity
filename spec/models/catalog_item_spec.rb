require 'rails_helper'

RSpec.describe CatalogItem, type: :model do
  describe 'associations' do
    it { should belong_to(:brand) }
    it { should belong_to(:item_category) }
    it { should belong_to(:item_subcategory).class_name('ItemCategory').optional }
    it { should belong_to(:country).optional }
    it { should have_many(:catalog_item_nodes).dependent(:destroy) }
    it { should have_many(:nodes).through(:catalog_item_nodes) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }

    describe 'subcategory' do
      let(:bois) { create(:item_category, name: 'Bois') }
      let(:sub) { create(:item_category, name: 'Moulin avec trémie extérieure', parent: bois) }

      it 'accepts a subcategory of the chosen category' do
        expect(build(:catalog_item, item_category: bois, item_subcategory: sub)).to be_valid
      end

      it 'rejects a subcategory of another category' do
        item = build(:catalog_item, item_category: create(:item_category), item_subcategory: sub)
        expect(item).not_to be_valid
        expect(item.errors[:item_subcategory]).to be_present
      end

      it 'rejects a subcategory used as the main category' do
        item = build(:catalog_item, item_category: sub)
        expect(item).not_to be_valid
        expect(item.errors[:item_category]).to be_present
      end
    end
  end
end
