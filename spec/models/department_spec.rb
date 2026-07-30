require 'rails_helper'

RSpec.describe Department, type: :model do
  describe 'associations' do
    it { should belong_to(:brand) }
    it { should have_many(:catalog_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }

    it 'validates uniqueness of name scoped to brand' do
      brand = create(:brand)
      create(:department, name: 'Sales', brand: brand)

      duplicate = build(:department, name: 'Sales', brand: brand)
      expect(duplicate).not_to be_valid

      other_brand_department = build(:department, name: 'Sales', brand: create(:brand))
      expect(other_brand_department).to be_valid
    end
  end
end
