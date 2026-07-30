require 'rails_helper'

RSpec.describe CatalogItem, type: :model do
  describe 'associations' do
    it { should belong_to(:brand) }
    it { should belong_to(:item_category) }
    it { should belong_to(:country).optional }
    it { should belong_to(:department).optional }
    it { should have_many(:catalog_item_nodes).dependent(:destroy) }
    it { should have_many(:nodes).through(:catalog_item_nodes) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
  end

  describe 'department scoping' do
    it 'creates a new department scoped to the brand when new_department_name is given' do
      brand = create(:brand)
      catalog_item = build(:catalog_item, brand: brand, department: nil, new_department_name: 'Powertrain')

      expect(catalog_item).to be_valid
      expect(catalog_item.department.name).to eq('Powertrain')
      expect(catalog_item.department.brand).to eq(brand)
    end

    it 'is invalid when the department belongs to a different brand' do
      brand = create(:brand)
      other_brand_department = create(:department, brand: create(:brand))
      catalog_item = build(:catalog_item, brand: brand, department: other_brand_department)

      expect(catalog_item).not_to be_valid
      expect(catalog_item.errors[:department]).to be_present
    end
  end
end
