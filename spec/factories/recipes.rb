FactoryBot.define do
  factory :recipe do
    title { "test_recipe" }
    work_name { "test_book" }
    tip { "簡単" }
    recipe_image do
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'images', 'test_recipe_image.png'), 'image/png'
      )
    end
    servings_count { 1 }
    work_title { "test_title" }
    work_author { "test_author" }
    work_image { "https://example.png" }
    work_price { 1000 }
    work_url { "https://example.com" }
    association :user
    association :category

    after(:build) do |recipe|
      recipe.ingredients << build_list(:ingredient, 3, recipe: recipe)
      recipe.instructions << build_list(:instruction, 3, recipe: recipe)
    end
  end
end
