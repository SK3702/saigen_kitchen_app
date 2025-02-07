class FavoritesController < ApplicationController
  before_action :set_recipe
  before_action :authenticate_user!

  def create
    favorite = @recipe.favorites.find_or_create_by(user_id: current_user.id)
    favorite.save
    respond_to do |format|
      format.html { redirect_to recipe_path(@recipe) }
      format.js
    end
  end

  def destroy
    favorite = @recipe.favorites.find_by(user_id: current_user.id)
    favorite.destroy
    respond_to do |format|
      format.html { redirect_to recipe_path(@recipe) }
      format.js
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end
end
