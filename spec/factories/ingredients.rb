FactoryBot.define do
  factory :ingredient do
    name { "卵" }
    quantity { "2個" }
    association :recipe
  end
end
