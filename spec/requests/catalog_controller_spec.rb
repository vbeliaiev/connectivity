require 'rails_helper'

RSpec.describe CatalogController, type: :request do
  describe 'GET /catalog with a subcategory filter' do
    let(:bois) { create(:item_category, name: 'Bois') }
    let(:exterieure) { create(:item_category, name: 'Moulin avec trémie extérieure', parent: bois) }
    let(:interieure) { create(:item_category, name: 'Moulin avec trémie intérieure à calotte plate', parent: bois) }
    let!(:item_exterieure) { create(:catalog_item, title: 'Modèle Extérieur', item_category: bois, item_subcategory: exterieure) }
    let!(:item_interieure) { create(:catalog_item, title: 'Modèle Intérieur', item_category: bois, item_subcategory: interieure) }

    before { sign_in create(:user) }

    it 'lists only the items of the chosen subcategory' do
      get catalog_path(filter: { item_category_id: bois.id, item_subcategory_id: exterieure.id })

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Modèle Extérieur')
      expect(response.body).not_to include('Modèle Intérieur')
    end

    it 'enables the subcategory select with the chosen category subcategories' do
      get catalog_path(filter: { item_category_id: bois.id })

      select = response.body[/<select[^>]*filter\[item_subcategory_id\][^>]*>.*?<\/select>/m]
      expect(select).not_to include('disabled="disabled"')
      expect(select).to include('Moulin avec trémie extérieure', 'Moulin avec trémie intérieure à calotte plate')
    end

    it 'disables the subcategory select when no category is chosen' do
      get catalog_path

      select = response.body[/<select[^>]*filter\[item_subcategory_id\][^>]*>/]
      expect(select).to include('disabled="disabled"')
    end
  end
end
