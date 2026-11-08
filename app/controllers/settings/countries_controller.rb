# Settings > Pays: admin-only CRUD for catalog countries.
module Settings
  class CountriesController < ApplicationController
    layout 'settings'

    after_action :verify_pundit_authorization
    before_action :set_country, only: %i[edit update destroy]

    def index
      authorize Country
      load_countries
    end

    def create
      @new_country = Country.new(country_params)
      authorize @new_country

      if @new_country.save
        redirect_to settings_countries_path, notice: "Le pays « #{@new_country.name} » a été créé avec succès."
      else
        load_countries
        render :index, status: :unprocessable_entity
      end
    end

    def edit
      authorize @country
    end

    def update
      authorize @country

      if @country.update(country_params)
        redirect_to settings_countries_path, notice: "« #{@country.name} » a été mis à jour avec succès."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @country

      if @country.destroy
        redirect_to settings_countries_path, notice: "« #{@country.name} » a été supprimé avec succès."
      else
        redirect_to settings_countries_path, alert: @country.errors.map(&:message).join(' ')
      end
    end

    private

    def set_country
      @country = Country.find(params[:id])
    end

    def load_countries
      @countries = policy_scope(Country).order(:name)
      @items_count_by_country = CatalogItem.where.not(country_id: nil).group(:country_id).count
    end

    def country_params
      params.require(:country).permit(:name)
    end
  end
end
