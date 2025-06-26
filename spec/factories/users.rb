FactoryBot.define do
  factory :user do
    email { FFaker::Internet.unique.email }
    password { "password123" }
    display_name { FFaker::Name.unique.first_name }
  end
end
