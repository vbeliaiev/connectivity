FactoryBot.define do
  factory :note do
    title { FFaker::Lorem.sentence }
    sequence(:position)
    #type { "Note" }
    association :author, factory: :user


    after(:build) do |note|
      note.page = ActionText::RichText.new(body: FFaker::Lorem.paragraph)
      note.organisation ||= note.author.personal_organisation
    end
  end
end