FactoryBot.define do
  factory :instruction do
    sequence(:step) { |n| n }
    description { "手順の説明" }
    association :recipe
  end
end
