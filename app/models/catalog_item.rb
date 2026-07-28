class CatalogItem < ApplicationRecord
  belongs_to :brand
  belongs_to :country, optional: true

  has_many :catalog_item_nodes, dependent: :destroy
  has_many :nodes, through: :catalog_item_nodes

  has_rich_text :description
  has_one_attached :cover

  MAX_COVER_SIZE = 60.megabytes
  MAX_FIELD_LENGTH = 180

  # Let the form offer a "add a new brand/country" text field instead of
  # forcing the user to pick one that already exists in the list.
  attr_accessor :new_brand_title, :new_country_name

  before_validation :assign_new_brand, :assign_new_country

  validates :title, presence: true, length: { maximum: MAX_FIELD_LENGTH }
  validates :model, length: { maximum: MAX_FIELD_LENGTH }
  validates :production_start_year, :production_end_year, numericality: { only_integer: true }, allow_nil: true
  validate :acceptable_cover

  # Full text search on title, using PostgreSQL's tsvector/tsquery.
  #
  # We use the 'simple' text search config on purpose instead of 'french':
  # titles are mostly proper nouns and short model codes (e.g. "A", "G",
  # "EX", "T"), and the 'french' dictionary treats these as stopwords and
  # silently drops them from the query, causing false positive matches.
  # 'simple' keeps every token as-is (just lowercases it), so short codes
  # are matched exactly.
  #
  # immutable_unaccent() strips accents on both sides of the match so
  # "decapotable" also matches "Décapotable", while still avoiding the
  # stemming/stopword issues of the 'french' config.
  #
  # Each word of the query is matched as a prefix so results show up as the
  # user types, and all words must match (AND) for a catalog item to be
  # included.
  scope :search_by_title, lambda { |query|
    terms = query.to_s.strip.split(/\s+/).map { |term| term.gsub(/['&|!():]/, '') }.reject(&:blank?)
    next all if terms.empty?

    tsquery = terms.map { |term| "#{term}:*" }.join(' & ')
    where(
      "to_tsvector('simple', public.immutable_unaccent(catalog_items.title)) @@ to_tsquery('simple', public.immutable_unaccent(?))",
      tsquery
    )
  }

  scope :by_brand, lambda { |brand_id|
    brand_id.present? ? where(brand_id: brand_id) : all
  }

  scope :by_country, lambda { |country_id|
    country_id.present? ? where(country_id: country_id) : all
  }

  # These two scopes are meant to be combined: they let users filter catalog
  # items whose production period overlaps with the [start_year, end_year]
  # range picked in the filters, rather than requiring an exact match.
  scope :by_production_start_year, lambda { |year|
    next all if year.blank?

    where('catalog_items.production_end_year >= ? OR catalog_items.production_end_year IS NULL', year)
  }

  scope :by_production_end_year, lambda { |year|
    next all if year.blank?

    where('catalog_items.production_start_year <= ? OR catalog_items.production_start_year IS NULL', year)
  }

  private

  def assign_new_brand
    title = new_brand_title.to_s.strip
    return if title.blank?

    self.brand = Brand.find_or_create_by(title: title)
  end

  def assign_new_country
    name = new_country_name.to_s.strip
    return if name.blank?

    self.country = Country.find_or_create_by(name: name)
  end

  def acceptable_cover
    return unless cover.attached?

    if cover.byte_size > MAX_COVER_SIZE
      errors.add(:cover, 'is too large (maximum is 60MB)')
    end

    unless cover.content_type.to_s.start_with?('image/')
      errors.add(:cover, 'must be an image')
    end
  end
end
