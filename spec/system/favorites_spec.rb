require "rails_helper"

RSpec.describe "Favorites", type: :system do
  let(:user) { create(:user) }
  let(:recipe) { create(:recipe) }

  describe "お気に入りボタン" do
    before do
      sign_in user
      visit recipe_path(recipe.id)
    end

    it "お気に入り登録ボタンが表示されていること" do
      expect(page).to have_link("お気に入り")
    end

    context "このレシピがお気に入りにされていない場合" do
      it "お気に入りボタンを押すと、ハートがピンクになること", js: true do
        find(".favorite-btn").click
        expect(page).to have_css(".bi-heart-fill")
      end
    end

    context "このレシピがお気に入りの場合" do
      before do
        create(:favorite, user: user, recipe: recipe)
        visit recipe_path(recipe)
        expect(page).to have_css(".bi-heart-fill")
      end

      it "お気に入りボタンを押すと、ハートが白になること", js: true do
        find(".favorite-btn").click
        expect(page).to have_css(".bi-heart")
      end
    end

    context "未ログイン場合" do
      it "お気に入りボタンを押すと、ログインしてくださいと出ること", js: true do
        sign_out user
        visit recipe_path(recipe.id)
        find(".favorite-btn").click
        expect(page).to have_content("ログインしてください")
      end
    end
  end

  describe "お気に入りレシピページ" do
    let!(:favorite) { create(:favorite, user_id: user.id, recipe_id: recipe.id) }
    let!(:other_recipe) { create(:recipe, title: "test_recipe2") }
    let!(:older_favorite) { create(:favorite, user_id: user.id, recipe_id: other_recipe.id, created_at: 1.day.ago) }

    before do
      sign_in user
      visit favorites_recipes_path
    end

    it "お気に入り登録したレシピ情報が表示されていること" do
      expect(page).to have_selector("img[src$='#{recipe.recipe_image.thumb.url}']")
      expect(page).to have_link(recipe.title, href: recipe_path(recipe.id))
      expect(page).to have_link(recipe.work_name, href: recipe_path(recipe.id))
      expect(page).to have_link(recipe.user.name, href: profile_path(recipe.user.id))
      expect(page).to have_css("a[href='#{profile_path(recipe.user.id)}'] img[src$='#{recipe.user.avatar.smaller.url}']")
    end

    it "レシピ情報押下でレシピページへ遷移すること" do
      all('.recipe-link').first.click
      expect(current_path).to eq recipe_path(other_recipe.id)
    end

    it "ユーザー情報押下でプロフィールページへ遷移すること" do
      all('.user-link').first.click
      expect(current_path).to eq profile_path(other_recipe.user.id)
    end

    it "お気に入りにした最新順から並んでいること" do
      display_recipes = all(".recipe-link")

      expect(display_recipes.first).to have_content(other_recipe.title)
      expect(display_recipes.last).to have_content(recipe.title)
    end

    it "ブラウザタブのタイトルが正しく表示されること" do
      expect(page).to have_title "お気に入りレシピ - 再現Kitchen"
    end
  end
end
