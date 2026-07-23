FactoryBot.define do
  factory :photo_gallery do
    title { FFaker::Lorem.sentence }
    sequence(:position)
    type { "PhotoGallery" }

    association :author, factory: :user

    after(:build) do |photo_gallery|
      photo_gallery.organisation ||= photo_gallery.author.personal_organisation
    end
  end
end
