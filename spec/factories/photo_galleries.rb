FactoryBot.define do
  factory :photo_gallery do
    title { FFaker::Lorem.sentence }
    sequence(:position)
    type { "PhotoGallery" }

    association :author, factory: :user
  end
end
