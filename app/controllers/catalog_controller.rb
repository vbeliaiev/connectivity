class CatalogController < ApplicationController
  layout 'catalog'

  before_action :redirect_unauthenticated_to_home
  before_action :current_sort

  CATALOG_ITEMS_MAX_COUNT = 10

  def show
    @catalog_items = CatalogItem
                      .includes(:item_category)
                      .search_by_title(params[:query])
                      .by_brand(filter_params[:brand_id])
                      .by_item_category(filter_params[:item_category_id])
                      .by_country(filter_params[:country_id])
                      .by_production_start_year(filter_params[:production_start_year])
                      .by_production_end_year(filter_params[:production_end_year])
                      .sorted_by(@sort)
                      .page(params[:catalog_items_page])
                      .per(CATALOG_ITEMS_MAX_COUNT)
  end

  private

  # Normalized here (rather than in the view) so the dropdown always shows a
  # selected option, even when the URL carries no or an unknown `sort` value.
  def current_sort
    @sort = CatalogItem::SORT_OPTIONS.key?(params[:sort]) ? params[:sort] : CatalogItem::DEFAULT_SORT
  end

  def filter_params
    params.fetch(:filter, {}).permit(:brand_id, :item_category_id, :country_id, :production_start_year, :production_end_year)
  end

  def redirect_unauthenticated_to_home
    redirect_to library_path unless user_signed_in?
  end
end
