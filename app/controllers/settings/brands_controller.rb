# Settings > Marques: admin-only CRUD for catalog brands.
module Settings
  class BrandsController < ApplicationController
    layout 'settings'

    after_action :verify_pundit_authorization
    before_action :set_brand, only: %i[edit update destroy]

    def index
      authorize Brand
      load_brands
    end

    def create
      @new_brand = Brand.new(brand_params)
      authorize @new_brand

      if @new_brand.save
        redirect_to settings_brands_path, notice: "La marque « #{@new_brand.title} » a été créée avec succès."
      else
        load_brands
        render :index, status: :unprocessable_entity
      end
    end

    def edit
      authorize @brand
    end

    def update
      authorize @brand

      if @brand.update(brand_params)
        redirect_to settings_brands_path, notice: "« #{@brand.title} » a été mis à jour avec succès."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @brand

      if @brand.destroy
        redirect_to settings_brands_path, notice: "« #{@brand.title} » a été supprimé avec succès."
      else
        redirect_to settings_brands_path, alert: @brand.errors.map(&:message).join(' ')
      end
    end

    private

    def set_brand
      @brand = Brand.find(params[:id])
    end

    def load_brands
      @brands = policy_scope(Brand).order(:title)
      @items_count_by_brand = CatalogItem.group(:brand_id).count
    end

    def brand_params
      params.require(:brand).permit(:title)
    end
  end
end
