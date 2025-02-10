FactoryBot.define do
  factory :contact do
    name { "テストユーザー" }
    email { "test@example.com" }
    subject { "テスト件名" }
    message { "これはテストメッセージです。" }
  end
end
