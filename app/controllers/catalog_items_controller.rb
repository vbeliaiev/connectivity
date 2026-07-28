class CatalogItemsController < ApplicationController
  layout 'catalog'

  after_action :verify_pundit_authorization
  before_action :set_catalog_item, only: %i[ show edit update destroy ]

  def show
    authorize @catalog_item
  end

  def new
    @catalog_item = CatalogItem.new
    authorize @catalog_item
  end

  def edit
    authorize @catalog_item
  end

  def create
    @catalog_item = CatalogItem.new(catalog_item_params)
    authorize @catalog_item

    if @catalog_item.save
      redirect_to @catalog_item, notice: "L'élément du catalogue a été créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @catalog_item

    @catalog_item.cover.purge if params.dig(:catalog_item, :remove_cover) == '1'

    if @catalog_item.update(catalog_item_params)
      redirect_to @catalog_item, notice: "L'élément du catalogue a été mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @catalog_item

    if @catalog_item.destroy!
      redirect_to catalog_path, notice: "L'élément du catalogue a été supprimé avec succès."
    else
      redirect_to @catalog_item, alert: "L'élément du catalogue n'a pas pu être supprimé. Veuillez réessayer et prévenir l'administrateur."
    end
  end

  private

  def set_catalog_item
    @catalog_item = CatalogItem.find(params[:id])
  end

  def catalog_item_params
    params.require(:catalog_item).permit(:title, :brand_id, :new_brand_title, :model, :country_id, :new_country_name, :production_start_year, :production_end_year, :cover, :description)
  end
end
