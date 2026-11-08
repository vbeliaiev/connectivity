# Settings > Categories: admin-only CRUD for catalog categories and their
# subcategories. A subcategory is created by posting a parent_id along with
# the name; categories without parent_id are top-level.
module Settings
  class ItemCategoriesController < ApplicationController
    layout 'settings'

    after_action :verify_pundit_authorization
    before_action :set_item_category, only: %i[edit update destroy]

    def index
      authorize ItemCategory
      load_categories
    end

    def create
      @new_item_category = ItemCategory.new(create_params)
      authorize @new_item_category

      if @new_item_category.save
        redirect_to settings_path, notice: created_notice(@new_item_category)
      else
        load_categories
        render :index, status: :unprocessable_entity
      end
    end

    def edit
      authorize @item_category
    end

    def update
      authorize @item_category

      if @item_category.update(update_params)
        redirect_to settings_path, notice: "« #{@item_category.name} » a été mis à jour avec succès."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @item_category

      if @item_category.destroy
        redirect_to settings_path, notice: "« #{@item_category.name} » a été supprimé avec succès."
      else
        redirect_to settings_path, alert: @item_category.errors.map(&:message).join(' ')
      end
    end

    private

    def set_item_category
      @item_category = ItemCategory.find(params[:id])
    end

    def load_categories
      @item_categories = policy_scope(ItemCategory).roots.order(:name).includes(:subcategories)
      @items_count_by_category = CatalogItem.group(:item_category_id).count
      @items_count_by_subcategory = CatalogItem.where.not(item_subcategory_id: nil).group(:item_subcategory_id).count
    end

    def create_params
      params.require(:item_category).permit(:name, :parent_id)
    end

    # Only renaming is supported: moving a category to another parent
    # would leave its catalog items pointing at a mismatched pair.
    def update_params
      params.require(:item_category).permit(:name)
    end

    def created_notice(item_category)
      if item_category.root?
        "La catégorie « #{item_category.name} » a été créée avec succès."
      else
        "La sous-catégorie « #{item_category.name} » a été ajoutée à « #{item_category.parent.name} »."
      end
    end
  end
end
