require 'rails_helper'

RSpec.describe CatalogItemNode, type: :model do
  describe 'associations' do
    it { should belong_to(:node) }
    it { should belong_to(:catalog_item) }
  end
end
