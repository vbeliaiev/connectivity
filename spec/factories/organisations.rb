FactoryBot.define do
  factory :organisation do
    name { FFaker::Lorem.unique.word }
  end
end
