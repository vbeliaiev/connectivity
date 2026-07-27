FactoryBot.define do
  factory :article do
    title { FFaker::Lorem.sentence }
    sequence(:position)
    association :author, factory: :user


    after(:build) do |article|
      if article.page.body.blank?
        article.page = ActionText::RichText.new(body: FFaker::Lorem.paragraph)
      end
    end
  end
end
