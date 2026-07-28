FactoryBot.define do
  factory :brand do
    sequence(:title) { |n| "#{FFaker::Company.name} #{n}" }
  end
end
