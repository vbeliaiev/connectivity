FactoryBot.define do
  factory :folder do
    title { FFaker::Lorem.word }
    sequence(:position)

    association :author, factory: :user
    type { "Folder" }
    parent { nil }
  end

end
