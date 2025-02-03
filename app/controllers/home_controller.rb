class HomeController < ApplicationController
  TOP_PAGE_RECIPE_COUNT = 3

  def index
    category_ids = [1, 2, 3, 4]
    @recipe_categories = Category.where(id: category_ids).map do |category|
      {
        category: category,
        recipes: category.recipes.recent.limit(TOP_PAGE_RECIPE_COUNT),
      }
    end
  end
end
