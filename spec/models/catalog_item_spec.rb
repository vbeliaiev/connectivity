require 'rails_helper'

RSpec.describe CatalogItem, type: :model do
  describe 'associations' do
    it { should belong_to(:brand) }
    it { should belong_to(:country).optional }
    it { should have_many(:catalog_item_nodes).dependent(:destroy) }
    it { should have_many(:nodes).through(:catalog_item_nodes) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
  end
end
