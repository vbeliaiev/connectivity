require 'rails_helper'

RSpec.describe Settings::CountriesController, type: :request do
  describe 'as an admin' do
    before { sign_in create(:user, :admin) }

    describe 'GET /settings/countries' do
      it 'lists countries and highlights the Pays entry' do
        create(:country, name: 'France')

        get settings_countries_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('France')
        expect(response.body).to match(/aria-current="page"[^>]*>.*?Pays/m)
      end
    end

    describe 'POST /settings/countries' do
      it 'creates a country' do
        expect do
          post settings_countries_path, params: { country: { name: ' France ' } }
        end.to change(Country, :count).by(1)

        expect(response).to redirect_to(settings_countries_path)
        expect(Country.last.name).to eq('France')
      end

      it 're-renders the page with an error for a duplicate name' do
        create(:country, name: 'France')

        expect do
          post settings_countries_path, params: { country: { name: 'France' } }
        end.not_to change(Country, :count)

        expect(response).to have_http_status(422)
        expect(response.body).to include('Ce pays existe déjà')
      end
    end

    describe 'PATCH /settings/countries/:id' do
      it 'renames a country' do
        country = create(:country, name: 'Allemagne')

        patch settings_country_path(country), params: { country: { name: 'Allemagne (RFA)' } }

        expect(response).to redirect_to(settings_countries_path)
        expect(country.reload.name).to eq('Allemagne (RFA)')
      end
    end

    describe 'DELETE /settings/countries/:id' do
      it 'deletes an unused country' do
        country = create(:country)

        delete settings_country_path(country)

        expect(response).to redirect_to(settings_countries_path)
        expect(Country.exists?(country.id)).to be(false)
      end

      it 'keeps a country used by catalog items and explains why' do
        item = create(:catalog_item)

        delete settings_country_path(item.country)

        expect(flash[:alert]).to include('élément(s) du catalogue')
        expect(Country.exists?(item.country_id)).to be(true)
      end
    end
  end
end
