FactoryBot.define do
  factory :catalog_item_node do
    association :node, factory: :folder
    association :catalog_item
  end
end
