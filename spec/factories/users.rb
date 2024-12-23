FactoryBot.define do
  factory :user do
    name { "test" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "testuser" }
    password_confirmation { "testuser" }
    bio { "Hello." }
    avatar { Rack::Test::UploadedFile.new(Rails.root.join('app/assets/images/default.png'), 'image/png') }
  end
end
