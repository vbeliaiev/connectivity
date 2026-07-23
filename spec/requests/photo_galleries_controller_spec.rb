require 'rails_helper'

RSpec.describe PhotoGalleriesController, type: :request do
  let(:current_user) { create(:user) }
  let(:current_user_org) { create(:organisation) }
  let(:test_image) { Rails.root.join('spec/fixtures/files/test_image.png') }

  before do
    current_user.confirm
    current_user.update(current_organisation_id: current_user_org.id)
    create(:organisations_user, user: current_user, organisation: current_user_org)
    sign_in current_user
  end

  describe 'GET /photo_galleries/new' do
    it 'returns a successful response' do
      get new_photo_gallery_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /photo_galleries' do
    let(:folder) { create(:folder, organisation: current_user_org, author: current_user) }

    let(:valid_params) do
      {
        photo_gallery: {
          title: 'Summer trip',
          parent_id: folder.id,
          images: [Rack::Test::UploadedFile.new(test_image, 'image/png')]
        }
      }
    end

    it 'creates a photo gallery with an item and redirects to the parent folder' do
      expect {
        post photo_galleries_path, params: valid_params
      }.to change(PhotoGallery, :count).by(1).and change(GalleryItem, :count).by(1)

      gallery = PhotoGallery.order(:created_at).last
      expect(response).to redirect_to(folder_path(folder))
      expect(gallery.items.first).to be_cover
    end

    it 'does not create a gallery without any photos' do
      expect {
        post photo_galleries_path, params: { photo_gallery: { title: 'No photos', parent_id: folder.id } }
      }.not_to change(PhotoGallery, :count)

      expect(response).to have_http_status(422)
    end

    context 'with multiple photos where the cover is not the first one' do
      let(:multi_params) do
        {
          photo_gallery: {
            title: 'Multi photo gallery',
            parent_id: folder.id,
            images: [
              Rack::Test::UploadedFile.new(test_image, 'image/png'),
              Rack::Test::UploadedFile.new(test_image, 'image/png'),
              Rack::Test::UploadedFile.new(test_image, 'image/png')
            ],
            cover_selection: 'new:1'
          }
        }
      end

      it 'attaches a real, downloadable file to every item, including the chosen cover' do
        post photo_galleries_path, params: multi_params

        gallery = PhotoGallery.order(:created_at).last
        service = ActiveStorage::Blob.service

        gallery.items.ordered.each do |item|
          expect(item.image).to be_attached
          expect(service.exist?(item.image.blob.key)).to be(true)
        end

        expect(gallery.items.ordered.to_a[1]).to be_cover
      end
    end
  end

  describe 'GET /photo_galleries/:id' do
    let(:gallery) { create(:photo_gallery, author: current_user, organisation: current_user_org) }
    let!(:item1) { create(:gallery_item, gallery: gallery, cover: true) }
    let!(:item2) { create(:gallery_item, gallery: gallery) }

    it 'returns a successful response and shows the gallery title' do
      get photo_gallery_path(gallery)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(gallery.title)
    end

    it 'selects the requested item_id as current when provided' do
      get photo_gallery_path(gallery, item_id: item2.id)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /photo_galleries/:id' do
    let(:gallery) { create(:photo_gallery, author: current_user, organisation: current_user_org) }
    let!(:item1) { create(:gallery_item, gallery: gallery, cover: true) }

    it 'updates the title' do
      patch photo_gallery_path(gallery), params: { photo_gallery: { title: 'Renamed' } }
      expect(response).to redirect_to(photo_gallery_path(gallery))
      expect(gallery.reload.title).to eq('Renamed')
    end

    it 'does not allow removing the last remaining photo' do
      patch photo_gallery_path(gallery), params: {
        photo_gallery: {
          title: gallery.title,
          items_attributes: { '0' => { id: item1.id, _destroy: '1' } }
        }
      }
      expect(response).to have_http_status(422)
      expect(gallery.items.count).to eq(1)
    end

    context 'when one of the items has no image attached (a broken item)' do
      let!(:broken_item) do
        gallery.items.build(position: 0, cover: true).tap { |item| item.save(validate: false) }
      end

      it 'allows deleting the broken item without being blocked by its own validation' do
        patch photo_gallery_path(gallery), params: {
          photo_gallery: {
            title: gallery.title,
            items_attributes: {
              '0' => { id: broken_item.id, _destroy: '1' },
              '1' => { id: item1.id, _destroy: '0' }
            }
          }
        }

        expect(response).to redirect_to(photo_gallery_path(gallery))
        expect(GalleryItem.exists?(broken_item.id)).to be_falsey
        expect(GalleryItem.exists?(item1.id)).to be_truthy
      end
    end
  end

  describe 'DELETE /photo_galleries/:id' do
    let(:gallery) { create(:photo_gallery, author: current_user, organisation: current_user_org) }
    let!(:item1) { create(:gallery_item, gallery: gallery, cover: true) }

    it 'destroys the gallery and its items' do
      expect {
        delete photo_gallery_path(gallery)
      }.to change(PhotoGallery, :count).by(-1).and change(GalleryItem, :count).by(-1)

      expect(response).to redirect_to(root_path)
    end
  end
end
