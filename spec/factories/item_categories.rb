FactoryBot.define do
  factory :item_category do
    sequence(:name) { |n| "#{FFaker::Product.brand} #{n}" }
  end
end
