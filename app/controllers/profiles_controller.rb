class ProfilesController < ApplicationController
  def show
    @user = User.find(params[:id])
    @posted_recipes = @user.recipes.order(created_at: :desc)
  end
end
