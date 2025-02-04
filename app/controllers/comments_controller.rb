class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :destroy]
  before_action :set_recipe, only: [:create, :destroy]
  before_action :set_comment, only: [:destroy]
  before_action :authorize_user, only: [:destroy]

  def create
    @comment = @recipe.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to recipe_path(@recipe)
    else
      flash[:alert] = @comment.errors.full_messages.join(", ")
      redirect_to recipe_path(@recipe)
    end
  end

  def destroy
    @comment.destroy
    redirect_to recipe_path(@recipe)
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end

  def set_comment
    @comment = @recipe.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def authorize_user
    unless @comment.user == current_user
      flash[:alert] = "自分のコメント以外の編集・削除はできません。"
      redirect_to recipe_path(@recipe)
    end
  end
end
