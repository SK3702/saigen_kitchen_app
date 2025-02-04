FactoryBot.define do
  factory :comment do
    content { "テストコメント" }
    association :user
    association :recipe
  end
end
