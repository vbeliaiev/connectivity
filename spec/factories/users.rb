FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    password { "password123" }
    display_name { FFaker::Name.first_name }
    role { :member }

    trait :moderator do
      role { :moderator }
    end

    trait :admin do
      role { :admin }
    end
  end
end
