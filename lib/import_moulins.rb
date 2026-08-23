require 'csv'
require 'pry'

class ImportMoulins
  IMG_ROOT = Rails.application.root.join('db', 'data', 'photos')
  CSV_DEFAULT_PATH = Rails.application.root.join('db', 'data', 'moulins_vlad.csv')
  def initialize(csv_path = CSV_DEFAULT_PATH)
    @csv_path = csv_path
    @img_root = IMG_ROOT
  end

  def clear_data
    CatalogItem.destroy_all
    Department.destroy_all
    Brand.destroy_all
    Country.destroy_all
    ItemCategory.destroy_all
  end

  # TODO: Option with batch insert
  # TODO: Option with idempotency + retry from the last failure
  # TODO: Default category ? "Non catégorisé"
  def call
    CSV.foreach(@csv_path, headers: true) do |row|
      brand = setup_brand(row['brand'])
      department = setup_department(row['department'], brand)
      item_category = setup_item_category(row['category'])
      country = setup_country(row['country'])
      cover = setup_cover(row['image'])

      CatalogItem.create(
        title: [brand&.title, row['model']].join(' - '),
        brand: brand,
        department: department,
        item_category: item_category,
        country: country,
        production_start_year: row['production_start_year'],
        production_end_year: row['production_end_year'],
        description: row['description'],
        cover: cover
      )
    end
  end

  private

  def setup_brand(brand_name)
    return unless brand_name

    @brands ||= {}
    return @brands[brand_name] if @brands[brand_name]

    brand = Brand.find_or_create_by(title: brand_name)
    @brands[brand_name] = brand

    brand
  end

  def setup_department(department_name, brand)
    return unless department_name

    @departments ||= Hash.new(Array.new([]))

    cached_department = @departments[brand.title].find { |d| d.name == department_name }
    return cached_department if cached_department

    department = brand.departments.find_or_create_by(name: department_name)
    @departments[brand.title] << department

    department
  end

  def setup_item_category(item_category_name)
    return unless item_category_name

    @item_categories ||= {}
    return @item_categories[item_category_name] if @item_categories[item_category_name]

    item_category = ItemCategory.find_or_create_by(name: item_category_name)
    @item_categories[item_category_name] = item_category

    item_category
  end

  def setup_country(country_name)
    return unless country_name

    @countries ||= {}
    return @countries[country_name] if @countries[country_name]

    country = Country.find_or_create_by(name: country_name)
    @countries[country_name] = country

    country
  end

  def setup_cover(image)
    return unless image

    begin
      File.open(@img_root.join(image))
    rescue Errno::ENOENT => e
      nil
    end
  end
end
