require 'rails_helper'

RSpec.describe Settings::BrandsController, type: :request do
  describe 'as an admin' do
    before { sign_in create(:user, :admin) }

    describe 'GET /settings/brands' do
      it 'lists brands and highlights the Marques entry' do
        create(:brand, title: 'Peugeot Frères')

        get settings_brands_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Peugeot Frères')
        expect(response.body).to match(/aria-current="page"[^>]*>.*?Marques/m)
      end
    end

    describe 'POST /settings/brands' do
      it 'creates a brand' do
        expect do
          post settings_brands_path, params: { brand: { title: ' Peugeot Frères ' } }
        end.to change(Brand, :count).by(1)

        expect(response).to redirect_to(settings_brands_path)
        expect(Brand.last.title).to eq('Peugeot Frères')
      end

      it 're-renders the page with an error for a duplicate title' do
        create(:brand, title: 'Peugeot Frères')

        expect do
          post settings_brands_path, params: { brand: { title: 'Peugeot Frères' } }
        end.not_to change(Brand, :count)

        expect(response).to have_http_status(422)
        expect(response.body).to include('Cette marque existe déjà')
      end
    end

    describe 'PATCH /settings/brands/:id' do
      it 'renames a brand' do
        brand = create(:brand, title: 'Peugeot')

        patch settings_brand_path(brand), params: { brand: { title: 'Peugeot Frères' } }

        expect(response).to redirect_to(settings_brands_path)
        expect(brand.reload.title).to eq('Peugeot Frères')
      end
    end

    describe 'DELETE /settings/brands/:id' do
      it 'deletes an unused brand' do
        brand = create(:brand)

        delete settings_brand_path(brand)

        expect(response).to redirect_to(settings_brands_path)
        expect(Brand.exists?(brand.id)).to be(false)
      end

      it 'keeps a brand used by catalog items and explains why' do
        item = create(:catalog_item)

        delete settings_brand_path(item.brand)

        expect(flash[:alert]).to include('élément(s) du catalogue')
        expect(Brand.exists?(item.brand_id)).to be(true)
      end
    end
  end
end
