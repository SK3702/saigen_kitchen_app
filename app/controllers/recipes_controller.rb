class RecipesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :favorites]
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]
  before_action :authorize_user, only: [:edit, :update, :destroy]
  before_action :get_categoties, onlu: [:new, :edit]

  def new
    @recipe = Recipe.new
    @recipe.ingredients.build
    @recipe.instructions.build
  end

  def create
    @recipe = current_user.recipes.new(recipe_params)
    if @recipe.save
      redirect_to recipe_path(@recipe)
    else
      render :new
    end
  end

  def show
    @user = User.find_by(params[:user_id])
    @is_author = current_user == @recipe.user
    @comment = Comment.new
  end

  def edit
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to recipe_path(@recipe)
    else
      render :edit
    end
  end

  def destroy
    @recipe.destroy
    redirect_to profile_path(current_user.id)
  end

  def favorites
    @favorite_recipes = current_user.favorite_recipes.includes(:user).order(created_at: :desc)
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :title, :work_name, :recipe_image, :tip, :category_id,
      ingredients_attributes: [:id, :name, :quantity, :_destroy],
      instructions_attributes: [:id, :step, :description, :_destroy]
    )
  end

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def get_categoties
    @categories = Category.all
  end

  def authorize_user
    unless @recipe.user == current_user
      flash[:alert] = "自分のレシピ以外の編集・削除はできません。"
      redirect_to profile_path(current_user)
    end
  end
end
