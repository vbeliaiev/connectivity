FactoryBot.define do
  factory :gallery_item do
    cover { false }
    sequence(:position)

    after(:build) do |item|
      unless item.image.attached?
        item.image.attach(
          io: File.open(Rails.root.join('spec/fixtures/files/test_image.png')),
          filename: 'test_image.png',
          content_type: 'image/png'
        )
      end
    end
  end
end
