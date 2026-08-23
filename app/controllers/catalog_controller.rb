class CatalogController < ApplicationController
  layout 'catalog'

  before_action :redirect_unauthenticated_to_home

  CATALOG_ITEMS_MAX_COUNT = 10

  def show
    @catalog_items = CatalogItem
                      .search_by_title(params[:query])
                      .by_brand(filter_params[:brand_id])
                      .by_item_category(filter_params[:item_category_id])
                      .by_country(filter_params[:country_id])
                      .by_department(filter_params[:department_id])
                      .by_production_start_year(filter_params[:production_start_year])
                      .by_production_end_year(filter_params[:production_end_year])
                      .order(updated_at: :desc)
                      .page(params[:catalog_items_page])
                      .per(CATALOG_ITEMS_MAX_COUNT)
  end

  private

  def filter_params
    params.fetch(:filter, {}).permit(:brand_id, :item_category_id, :country_id, :department_id, :production_start_year, :production_end_year)
  end

  def redirect_unauthenticated_to_home
    redirect_to library_path unless user_signed_in?
  end
end
