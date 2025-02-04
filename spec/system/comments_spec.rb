require "rails_helper"

RSpec.describe "Comments", type: :system do
  let(:user) { create(:user) }
  let(:recipe) { create(:recipe) }
  let!(:comment) { create(:comment, recipe_id: recipe.id, user_id: user.id) }

  before do
    sign_in user
    visit recipe_path(recipe)
  end

  describe "コメント表示" do
    it "コメントエリアに正しくコメントが表示されること" do
      within(".comments-area") do
        expect(page).to have_content(comment.content)
        expect(page).to have_content(user.name)
        expect(page).to have_selector("img[src$='#{user.avatar.smaller.url}']")
      end
    end
  end

  describe "コメント投稿" do
    it "正しい情報を入力するとコメントを投稿できること" do
      fill_in "コメント", with: "美味しかったです"
      click_button "投稿する"

      expect(page).to have_content("美味しかったです")
    end

    it "無効な情報を入力するとコメントを投稿できないこと" do
      fill_in "コメント", with: ""
      click_button "投稿する"

      expect(page).to have_content("コメント内容を入力してください")
    end
  end

  describe "コメント削除" do
    it "スリードットを押下で削除ボタンが表示されること", js: true do
      find("a.nav-link[data-bs-toggle='dropdown']").click
      expect(page).to have_link("削除", href: recipe_comment_path(recipe, comment))

      click_on "削除"
    end

    it "削除ボタンを押下でコメントが削除されること" do
      click_link "削除"

      expect(current_path).to eq(recipe_path(recipe))
      expect(page).not_to have_content(comment.content)
    end
  end
end
