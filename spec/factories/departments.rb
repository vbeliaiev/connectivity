FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "#{FFaker::Product.brand} #{n}" }
    association :brand
  end
end
