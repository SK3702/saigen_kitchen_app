require 'rails_helper'

RSpec.describe "Home", type: :request do
  let!(:categories) do
    create_list(:category, 2)
  end
  let!(:recipes) do
    create_list(:recipe, 4).each_with_index do |recipe, index|
      recipe.update(title: "test_recipe_#{index}")
    end
  end
  let!(:category_recipes) do
    create_list(:recipe, 4, category_id: categories[0].id).each_with_index do |recipe, index|
      recipe.update(created_at: index.day.ago)
    end
  end

  before do
    allow(Category).to receive(:where).with(id: [1, 2, 3, 4]).and_return(categories)
    recipes.each_with_index do |recipe, index|
      create_list(:favorite, index, recipe: recipe)
    end
    get root_path
  end

  describe "Get /" do
    it "レスポンスが正常であること" do
      expect(response).to have_http_status(200)
    end

    it "人気レシピセクションが含まれていること" do
      expect(response.body).to include("人気レシピ")
    end

    it "人気レシピとして人気のも最も高い3つのみが表示されること" do
      html = Nokogiri::HTML(response.body)
      popular_section = html.at_css('.popular-recipes-area')
      popular_text = popular_section.text
      expect(response.body).to include(recipes[1].title)
      expect(response.body).to include(recipes[2].title)
      expect(response.body).to include(recipes[3].title)
      expect(response.body).not_to include(recipes[0].title)
    end

    it "各カテゴリのレシピセクションが表示されていること" do
      get root_path
      categories.each do |category|
        expect(response.body).to include(category.name)
      end
    end

    it "カテゴリーに属するレシピが最新の3つのみ含まれていること" do
      puts response.body
      expect(response.body).to include(category_recipes[1].title)
      expect(response.body).to include(category_recipes[2].title)
      expect(response.body).to include(category_recipes[3].title)
      expect(response.body).not_to include(recipes[0].title)
    end
  end
end
