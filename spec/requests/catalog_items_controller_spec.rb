require 'rails_helper'

RSpec.describe CatalogItemsController, type: :request do
  let(:bois) { create(:item_category, name: 'Bois') }
  let(:exterieure) { create(:item_category, name: 'Trémie extérieure', parent: bois) }
  let!(:item) { create(:catalog_item, title: 'Modèle R', item_category: bois, item_subcategory: exterieure) }

  before { sign_in create(:user, :moderator) }

  describe 'GET /catalog_items/:id/edit' do
    it 'offers a blank option to remove the category and the subcategory' do
      get edit_catalog_item_path(item)

      category_select = response.body[/<select[^>]*catalog_item\[item_category_id\][^>]*>.*?<\/select>/m]
      subcategory_select = response.body[/<select[^>]*catalog_item\[item_subcategory_id\][^>]*>.*?<\/select>/m]
      expect(category_select).to include('<option value="">Aucune catégorie</option>')
      expect(subcategory_select).to include('<option value="">Aucune sous-catégorie</option>')
    end
  end

  describe 'PATCH /catalog_items/:id' do
    it 'removes only the subcategory' do
      patch catalog_item_path(item), params: { catalog_item: { item_category_id: bois.id, item_subcategory_id: '' } }

      expect(response).to redirect_to(catalog_item_path(item))
      item.reload
      expect(item.item_category).to eq(bois)
      expect(item.item_subcategory).to be_nil
    end

    it 'removes both the category and the subcategory' do
      # The subcategory <select> is disabled once the category is cleared,
      # so only its hidden blank field is submitted.
      patch catalog_item_path(item), params: { catalog_item: { item_category_id: '', item_subcategory_id: '' } }

      expect(response).to redirect_to(catalog_item_path(item))
      item.reload
      expect(item.item_category).to be_nil
      expect(item.item_subcategory).to be_nil
    end

    it 'refuses to keep a subcategory once the category is removed' do
      patch catalog_item_path(item), params: { catalog_item: { item_category_id: '', item_subcategory_id: exterieure.id } }

      expect(response).to have_http_status(422)
      expect(item.reload.item_category).to eq(bois)
    end
  end

  describe 'an item without category' do
    before { item.update!(item_category: nil, item_subcategory: nil) }

    it 'renders its page without the category row' do
      get catalog_item_path(item)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Modèle R')
      expect(response.body).not_to include('Catégorie :')
    end

    it 'is listed in the catalog without the category line' do
      get catalog_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Modèle R')
      expect(response.body).not_to include('<strong>Catégorie :</strong>')
    end
  end
end
