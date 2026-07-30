FactoryBot.define do
  factory :catalog_item do
    title { FFaker::Lorem.sentence }
    association :brand
    association :item_category
    association :country
    production_start_year { 1990 }
    production_end_year { 2000 }

    after(:build) do |catalog_item|
      if catalog_item.description.body.blank?
        catalog_item.description = ActionText::RichText.new(body: FFaker::Lorem.paragraph)
      end
    end
  end
end
