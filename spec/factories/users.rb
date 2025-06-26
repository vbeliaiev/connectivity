FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    password { "password123" }
    display_name { FFaker::Name.first_name }
  end
end
