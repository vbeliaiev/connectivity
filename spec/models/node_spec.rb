require 'rails_helper'

RSpec.describe Node, type: :model do
  describe 'associations' do
    it { should have_many(:children).class_name('Node').with_foreign_key('parent_id') }
    it { should belong_to(:parent).class_name('Node').optional }
    it { should have_many(:catalog_item_nodes).dependent(:destroy) }
    it { should have_many(:catalog_items).through(:catalog_item_nodes) }
  end

  describe 'scopes' do
    let!(:folder1) { create(:folder, title: 'A', position: 2, created_at: 2.days.ago) }
    let!(:folder2) { create(:folder, title: 'B', position: 1, created_at: 1.day.ago) }
    let!(:article1) { create(:article, title: 'Article1') }
    let!(:article2) { create(:article, title: 'Article2') }

    it '.folders returns only folders' do
      expect(Node.folders).to match_array([folder1, folder2])
    end

    it '.articles returns only articles' do
      expect(Node.articles).to match_array([article1, article2])
    end

    it '.ordered returns folders ordered by position ASC NULLS LAST, then created_at DESC' do
      # folder2 has position 1, folder1 has position 2
      expect(Node.folders.ordered).to eq([folder2, folder1])
    end
  end
end
