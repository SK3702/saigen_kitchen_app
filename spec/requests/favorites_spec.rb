require 'rails_helper'

RSpec.describe "Favorites", type: :request do
  let(:user)   { create(:user) }
  let(:recipe) { create(:recipe) }

  before { sign_in user }

  describe "POST /recipes/:recipe_id/favorite" do
    it "お気に入りが新規作成されること" do
      expect { post recipe_favorite_path(recipe) }.to change(Favorite, :count).by(1)
      expect(response).to redirect_to(recipe_path(recipe))
    end
  end

  describe "DELETE /recipes/:recipe_id/favorite" do
    let!(:favorite) { create(:favorite, user_id: user.id, recipe_id: recipe.id) }
    it "お気に入りが削除されること" do
      expect { delete recipe_favorite_path(recipe) }.to change(Favorite, :count).by(-1)
      expect(response).to redirect_to(recipe_path(recipe))
    end
  end
end
