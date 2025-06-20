FactoryBot.define do
  factory :folder do
    title { FFaker::Lorem.word }
    sequence(:position)
    type { "Folder" }
    parent { nil }
  end
end