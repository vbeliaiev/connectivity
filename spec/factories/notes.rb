FactoryBot.define do
  factory :note do
    title { FFaker::Lorem.sentence }
    sequence(:position)
    type { "Note" }

    after(:build) do |note|
      note.page = ActionText::RichText.new(body: FFaker::Lorem.paragraph)
    end
  end
end