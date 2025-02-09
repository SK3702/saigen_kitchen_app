require 'rails_helper'

RSpec.describe "Categories", type: :request do
  let!(:recipe) { create(:recipe, category_id: categories[0].id) }
  let(:categories) do
    create_list(:category, 2)
  end

  describe "GET /show" do
    before do
      get category_path(categories[0].id)
    end

    it "レスポンスが正常であること" do
      expect(response).to have_http_status(200)
    end

    it "カテゴリー名が含まれていること" do
      expect(response.body).to include(categories[0].name)
    end

    it "カテゴリーリストが含まれてこと" do
      categories.each do |category|
        expect(response.body).to include(category.name)
      end
    end

    it "カテゴリーのレシピデータが含まれており、他のカテゴリーのレシピデータが含まれていないこと" do
      other_recipe = create(:recipe, title: "test_recipe2", category_id: categories[1].id)
      expect(response.body).to include(recipe.title, recipe.work_name,
        recipe.user.name, "src=\"#{recipe.recipe_image.thumb.url}\"")
      expect(response.body).not_to include(other_recipe.title)
    end
  end
end
