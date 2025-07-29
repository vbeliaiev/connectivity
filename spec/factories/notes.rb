FactoryBot.define do
  factory :note do
    title { FFaker::Lorem.sentence }
    sequence(:position)
    #type { "Note" }
    association :author, factory: :user


    after(:build) do |note|
      if note.page.body.blank?
        note.page = ActionText::RichText.new(body: FFaker::Lorem.paragraph)
      end
      
      note.organisation ||= note.author.personal_organisation
    end
  end
end