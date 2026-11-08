require 'rails_helper'

RSpec.describe ItemCategory, type: :model do
  describe 'associations' do
    it { should have_many(:catalog_items) }
    it { should belong_to(:parent).class_name('ItemCategory').optional }
    it { should have_many(:subcategories).class_name('ItemCategory').with_foreign_key(:parent_id) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name).with_message('Le nom est obligatoire') }

    it 'allows the same subcategory name under different categories' do
      bois = create(:item_category, name: 'Bois')
      fonte = create(:item_category, name: 'Fonte')
      create(:item_category, name: 'Moulin avec trémie extérieure', parent: bois)

      expect(build(:item_category, name: 'Moulin avec trémie extérieure', parent: fonte)).to be_valid
    end

    it 'rejects a duplicate name at the same level' do
      bois = create(:item_category, name: 'Bois')
      create(:item_category, name: 'Moulin avec trémie extérieure', parent: bois)

      expect(build(:item_category, name: 'Bois')).not_to be_valid
      expect(build(:item_category, name: 'Moulin avec trémie extérieure', parent: bois)).not_to be_valid
    end

    it 'only allows two levels' do
      bois = create(:item_category)
      sub = create(:item_category, parent: bois)

      expect(build(:item_category, parent: sub)).not_to be_valid
    end
  end

  describe '.roots' do
    it 'returns only top-level categories' do
      bois = create(:item_category)
      create(:item_category, parent: bois)

      expect(described_class.roots).to contain_exactly(bois)
    end
  end

  describe '#destroy' do
    it 'refuses to delete a category that has subcategories' do
      bois = create(:item_category)
      create(:item_category, parent: bois)

      expect(bois.destroy).to be(false)
      expect(bois.errors[:base].first).to include('sous-catégories')
    end

    it 'refuses to delete a category used by catalog items' do
      item = create(:catalog_item)

      expect(item.item_category.destroy).to be(false)
      expect(described_class.exists?(item.item_category_id)).to be(true)
    end

    it 'refuses to delete a subcategory used by catalog items' do
      sub = create(:item_category, parent: create(:item_category))
      create(:catalog_item, item_category: sub.parent, item_subcategory: sub)

      expect(sub.destroy).to be(false)
    end

    it 'deletes an unused category' do
      category = create(:item_category)

      expect { category.destroy }.to change(described_class, :count).by(-1)
    end
  end
end
