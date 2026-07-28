class CatalogController < ApplicationController
  layout 'catalog'

  CATALOG_ITEMS_MAX_COUNT = 50

  def show
    @catalog_items = CatalogItem
                      .search_by_title(params[:query])
                      .by_brand(filter_params[:brand_id])
                      .by_country(filter_params[:country_id])
                      .by_production_start_year(filter_params[:production_start_year])
                      .by_production_end_year(filter_params[:production_end_year])
                      .order(:title)
                      .page(params[:catalog_items_page])
                      .per(CATALOG_ITEMS_MAX_COUNT)
  end

  private

  def filter_params
    params.fetch(:filter, {}).permit(:brand_id, :country_id, :production_start_year, :production_end_year)
  end
end
