require 'rails_helper'

# Every page and every write action of the settings area (categories,
# subcategories, brands, countries) must be reachable by admins only.
# Guests, members and moderators are redirected to the home page and
# nothing changes in the database.
RSpec.describe 'Settings authorization', type: :request do
  let!(:category) { create(:item_category, name: 'Bois') }
  let!(:subcategory) { create(:item_category, name: 'Moulin avec trémie extérieure', parent: category) }
  let!(:brand) { create(:brand, title: 'Peugeot Frères') }
  let!(:country) { create(:country, name: 'France') }

  def reference_counts
    [ItemCategory.count, Brand.count, Country.count]
  end

  shared_examples 'a forbidden settings area' do
    it 'cannot open the settings pages' do
      [settings_path, settings_brands_path, settings_countries_path,
       edit_settings_item_category_path(category), edit_settings_item_category_path(subcategory),
       edit_settings_brand_path(brand), edit_settings_country_path(country)].each do |path|
        get path
        expect(response).to redirect_to(root_path), "expected #{path} to be forbidden"
      end
    end

    it 'cannot create a category, a subcategory, a brand or a country' do
      expect do
        post settings_item_categories_path, params: { item_category: { name: 'Fonte' } }
        expect(response).to redirect_to(root_path)
        post settings_item_categories_path, params: { item_category: { name: 'Nouvelle', parent_id: category.id } }
        expect(response).to redirect_to(root_path)
        post settings_brands_path, params: { brand: { title: 'Japy' } }
        expect(response).to redirect_to(root_path)
        post settings_countries_path, params: { country: { name: 'Allemagne' } }
        expect(response).to redirect_to(root_path)
      end.not_to(change { reference_counts })
    end

    it 'cannot rename a category, a subcategory, a brand or a country' do
      patch settings_item_category_path(category), params: { item_category: { name: 'Changé' } }
      expect(response).to redirect_to(root_path)
      patch settings_item_category_path(subcategory), params: { item_category: { name: 'Changé' } }
      expect(response).to redirect_to(root_path)
      patch settings_brand_path(brand), params: { brand: { title: 'Changé' } }
      expect(response).to redirect_to(root_path)
      patch settings_country_path(country), params: { country: { name: 'Changé' } }
      expect(response).to redirect_to(root_path)

      expect(category.reload.name).to eq('Bois')
      expect(subcategory.reload.name).to eq('Moulin avec trémie extérieure')
      expect(brand.reload.title).to eq('Peugeot Frères')
      expect(country.reload.name).to eq('France')
    end

    it 'cannot delete a category, a subcategory, a brand or a country' do
      expect do
        delete settings_item_category_path(subcategory)
        expect(response).to redirect_to(root_path)
        delete settings_brand_path(brand)
        expect(response).to redirect_to(root_path)
        delete settings_country_path(country)
        expect(response).to redirect_to(root_path)
      end.not_to(change { reference_counts })
    end
  end

  context 'as a guest' do
    it_behaves_like 'a forbidden settings area'
  end

  context 'as a member' do
    before { sign_in create(:user) }

    it_behaves_like 'a forbidden settings area'
  end

  context 'as a moderator' do
    before { sign_in create(:user, :moderator) }

    it_behaves_like 'a forbidden settings area'

    # Moderators manage catalog items, but the item form must not be a
    # back door for creating brands, categories or countries.
    it 'cannot create a brand, a category or a country through the catalog item form' do
      expect do
        post catalog_items_path, params: {
          catalog_item: { title: 'Modèle', brand_id: brand.id, item_category_id: category.id, country_id: country.id,
                          new_brand_title: 'Japy', new_item_category_name: 'Fonte', new_country_name: 'Allemagne' }
        }
      end.to change(CatalogItem, :count).by(1)

      expect(reference_counts).to eq([2, 1, 1])
      expect(CatalogItem.last.country).to eq(country)
    end

    it 'no longer sees an "add a new country" field in the catalog item form' do
      get new_catalog_item_path

      expect(response.body).not_to include('new_country_name', 'Ajouter un nouveau pays')
    end
  end

  context 'the admin sections box (members + settings links)' do
    it 'is shown to admins only, on both the library and the catalog pages' do
      [library_path, catalog_path].each do |path|
        sign_in create(:user, :moderator)
        get path
        expect(response.body).not_to include('id="admin-sections"'), "expected no admin box on #{path} for a moderator"
        expect(response.body).not_to include(%(href="#{settings_path}"))

        sign_in create(:user, :admin)
        get path
        expect(response.body).to include('id="admin-sections"'), "expected the admin box on #{path} for an admin"
        expect(response.body).to include(%(href="#{settings_path}"), %(href="#{users_path}"))
      end
    end
  end
end
