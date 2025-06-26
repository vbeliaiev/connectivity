FactoryBot.define do
  factory :folder do
    title { FFaker::Lorem.word }
    sequence(:position)

    association :author, factory: :user
    type { "Folder" }
    parent { nil }

    after(:build) do |folder, evaluator|
      folder.organisation ||= folder.author.personal_organisation
    end
  end

end