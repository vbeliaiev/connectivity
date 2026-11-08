require 'rails_helper'

RSpec.describe Settings::ItemCategoriesController, type: :request do
  let(:admin) { create(:user, :admin) }

  describe 'as an admin' do
    before { sign_in admin }

    describe 'GET /settings' do
      it 'lists categories with their subcategories and highlights the Categories entry' do
        bois = create(:item_category, name: 'Bois')
        create(:item_category, name: 'Moulin avec trémie extérieure', parent: bois)

        get settings_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Bois', 'Moulin avec trémie extérieure')
        expect(response.body).to match(/aria-current="page"[^>]*>.*?Catégories/m)
      end
    end

    describe 'POST /settings/item_categories' do
      it 'creates a top-level category' do
        expect do
          post settings_item_categories_path, params: { item_category: { name: '  Bois  ' } }
        end.to change(ItemCategory.roots, :count).by(1)

        expect(response).to redirect_to(settings_path)
        expect(ItemCategory.last.name).to eq('Bois')
      end

      it 'creates a subcategory' do
        bois = create(:item_category, name: 'Bois')

        post settings_item_categories_path,
             params: { item_category: { name: 'Moulin avec trémie intérieure à calotte plate', parent_id: bois.id } }

        expect(response).to redirect_to(settings_path)
        expect(bois.subcategories.pluck(:name)).to eq(['Moulin avec trémie intérieure à calotte plate'])
      end

      it 're-renders the page with an error for a duplicate name' do
        create(:item_category, name: 'Bois')

        expect do
          post settings_item_categories_path, params: { item_category: { name: 'Bois' } }
        end.not_to change(ItemCategory, :count)

        expect(response).to have_http_status(422)
        expect(response.body).to include('Ce nom existe déjà à ce niveau')
      end
    end

    describe 'PATCH /settings/item_categories/:id' do
      it 'renames a category but ignores parent_id' do
        bois = create(:item_category, name: 'Bois')
        other = create(:item_category, name: 'Fonte')

        patch settings_item_category_path(bois), params: { item_category: { name: 'Bois tourné', parent_id: other.id } }

        expect(response).to redirect_to(settings_path)
        bois.reload
        expect(bois.name).to eq('Bois tourné')
        expect(bois.parent_id).to be_nil
      end
    end

    describe 'DELETE /settings/item_categories/:id' do
      it 'deletes an unused category' do
        category = create(:item_category)

        delete settings_item_category_path(category)

        expect(response).to redirect_to(settings_path)
        expect(ItemCategory.exists?(category.id)).to be(false)
      end

      it 'keeps a category used by catalog items and explains why' do
        item = create(:catalog_item)

        delete settings_item_category_path(item.item_category)

        expect(response).to redirect_to(settings_path)
        expect(flash[:alert]).to include('élément(s) du catalogue')
        expect(ItemCategory.exists?(item.item_category_id)).to be(true)
      end
    end
  end

  context 'authorization' do
    it 'denies a moderator' do
      sign_in create(:user, :moderator)
      get settings_path
      expect(response).to redirect_to(root_path)
    end

    it 'denies a member from creating categories' do
      sign_in create(:user)
      expect do
        post settings_item_categories_path, params: { item_category: { name: 'Bois' } }
      end.not_to change(ItemCategory, :count)
      expect(response).to redirect_to(root_path)
    end

    it 'denies a guest' do
      get settings_path
      expect(response).to redirect_to(root_path)
    end
  end
end
