require "rails_helper"

RSpec.describe "Recipes", type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:recipe) { create(:recipe, user_id: user.id) }
  let!(:category) { create(:category, name: "マンガ") }
  let!(:other_category) { create(:category, name: "アニメ") }

  describe "レシピ投稿" do
    before do
      sign_in user
      visit new_recipe_path
    end

    it "正しい情報を入力するとレシピを投稿できること", js: true do
      fill_in "レシピタイトル", with: "new_recipe"
      fill_in "作品名", with: "new_book"
      select "マンガ", from: "カテゴリー"
      attach_file("料理画像", image_file_path("test_recipe_image.png"))
      fill_in "ポイント・コツ", with: "難しいです。"
      fill_in "recipe[ingredients_attributes[0][name]]", with: "小麦粉"
      fill_in "recipe[ingredients_attributes[0][quantity]]", with: "100g"
      fill_in "recipe[instructions_attributes[0][description]]", with: "新しい手順の説明"

      fill_in "keyword", with: "ワンピース"
      find('#work_search_button').click
      first('#work_suggestions li').click
      click_button "投稿する"

      created_recipe = Recipe.last
      expect(current_path).to eq recipe_path(created_recipe.id)
      expect(page).to have_content(created_recipe.title)
      expect(page).to have_content(created_recipe.work_name)
      expect(page).to have_content(created_recipe.category.name)
      expect(page).to have_selector("img[src$='#{created_recipe.recipe_image.url}']")
      expect(page).to have_content(created_recipe.tip)
      created_recipe.ingredients.each do |ingredient|
        expect(page).to have_content(ingredient.name)
        expect(page).to have_content(ingredient.quantity)
      end
      created_recipe.instructions.each do |instruction|
        expect(page).to have_content(instruction.step)
        expect(page).to have_content(instruction.description)
      end
      expect(page).to have_content(created_recipe.work_title)
      expect(page).to have_content(created_recipe.work_author)
      expect(page).to have_selector("img[src$='#{created_recipe.work_image}']")
      expect(page).to have_content(created_recipe.work_price)
    end

    it "画像選択で画像プレビューが表示されること", js: true do
      attach_file("料理画像", image_file_path("test_recipe_image.png"))
      expect(page).to have_css("#new-image img")
    end

    it "無効な情報を入力するとレシピを投稿できないこと" do
      fill_in "レシピタイトル", with: ""
      fill_in "作品名", with: ""
      attach_file("料理画像", image_file_path("invalid_image.txt"))
      fill_in "ポイント・コツ", with: ""
      fill_in "recipe[ingredients_attributes[0][name]]", with: ""
      fill_in "recipe[ingredients_attributes[0][quantity]]", with: ""
      fill_in "recipe[instructions_attributes[0][description]]", with: ""
      click_button "投稿する"

      expect(current_path).to eq recipes_path
      expect(page).to have_content("カテゴリーを入力してください")
      expect(page).to have_content("料理画像は許可されていない拡張子です。")
      expect(page).to have_content("レシピタイトルを入力してください")
      expect(page).to have_content("作品名を入力してください")
      expect(page).to have_content("料理画像を入力してください")
      expect(page).to have_content("ポイント・コツを入力してください")
      expect(page).to have_content("材料を少なくとも1つ追加してください。")
      expect(page).to have_content("手順を少なくとも1つ追加してください。")
    end

    it "追加ボタンで材料のフォームが追加されること", js: true do
      within(".ingredients-wrapper") do
        click_button "+追加"
      end

      expect(page).to have_field("recipe[ingredients_attributes][1][name]")
      expect(page).to have_field("recipe[ingredients_attributes][1][quantity]")
    end

    it "追加ボタンで手順のフォームが追加されること", js: true do
      within(".instructions-wrapper") do
        click_button "+追加"
      end

      expect(page).to have_field("recipe[instructions_attributes][1][description]")
    end

    it "ブラウザタブのタイトルが正しく表示されること" do
      expect(page).to have_title "レシピ作成 - 再現Kitchen"
    end
  end

  describe "レシピ詳細ページ" do
    before do
      sign_in user
      visit recipe_path(recipe.id)
    end

    it "正しい情報が表示されること" do
      expect(page).to have_content(recipe.title)
      expect(page).to have_content(recipe.work_name)
      expect(page).to have_content(recipe.category.name)
      expect(page).to have_content(recipe.user.name)
      expect(page).to have_content(recipe.tip)
      expect(page).to have_selector("img[src$='#{recipe.recipe_image.url}']")
      recipe.ingredients.each do |ingredient|
        expect(page).to have_content(ingredient.name)
        expect(page).to have_content(ingredient.quantity)
      end
      recipe.instructions.each do |instruction|
        expect(page).to have_content(instruction.step)
        expect(page).to have_content(instruction.description)
      end
      expect(page).to have_content(recipe.work_title)
      expect(page).to have_content(recipe.work_author)
      expect(page).to have_selector("img[src$='#{recipe.work_image}']")
      expect(page).to have_content(recipe.work_price)
    end

    it "ログインユーザーが自分の投稿を編集できるリンクがあり、クリックで遷移すること" do
      click_link "編集する"
      expect(current_path).to eq(edit_recipe_path(recipe))
    end

    it "ユーザー名をクリックするとプロフィールページに遷移すること" do
      within(".recipe-area") do
        click_link user.name
      end
      expect(current_path).to eq(profile_path(user))
    end

    context "他のユーザーの場合" do
      it "編集ボタンが表示されないこと" do
        sign_in other_user
        visit recipe_path(recipe.id)
        expect(page).not_to have_link("編集する", href: edit_recipe_path(recipe))
      end
    end

    it "ブラウザタブのタイトルが正しく表示されること" do
      expect(page).to have_title "#{recipe.title} - 再現Kitchen"
    end
  end

  describe "レシピ編集" do
    before do
      sign_in user
      visit edit_recipe_path(recipe)
    end

    it "現在のレシピ情報が編集フォームに表示されていること" do
      expect(page).to have_field("レシピタイトル", with: recipe.title)
      expect(page).to have_field("作品名", with: recipe.work_name)
      expect(page).to have_select("カテゴリー", selected: recipe.category.name)
      expect(page).to have_field("ポイント・コツ", with: recipe.tip)
      expect(page).to have_selector("img[src$='#{recipe.recipe_image.url}']")
      recipe.ingredients.each_with_index do |ingredient, index|
        expect(page).to have_field("recipe[ingredients_attributes[#{index}][name]]", with: ingredient.name)
        expect(page).to have_field("recipe[ingredients_attributes[#{index}][quantity]]", with: ingredient.quantity)
      end
      recipe.instructions.each_with_index do |instruction, index|
        expect(page).to have_field("recipe[instructions_attributes[#{index}][description]]", with: instruction.description)
      end
    end

    it "正しい情報を入力するとレシピを編集できること", js: true do
      fill_in "レシピタイトル", with: "新しいタイトル"
      fill_in "作品名", with: "新しい作品名"
      select "アニメ", from: "カテゴリー"
      fill_in "ポイント・コツ", with: "新しいポイント"
      fill_in "recipe[ingredients_attributes[0][name]]", with: "新しい材料"
      fill_in "recipe[ingredients_attributes[0][quantity]]", with: "200g"
      fill_in "recipe[instructions_attributes[0][description]]", with: "新しい手順"

      fill_in "keyword", with: "鬼滅の刃"
      find('#work_search_button').click
      first('#work_suggestions li').click
      click_button "更新する"

      recipe.reload
      expect(current_path).to eq recipe_path(recipe.id)
      expect(page).to have_content(recipe.title)
      expect(page).to have_content(recipe.work_name)
      expect(page).to have_content(recipe.category.name)
      expect(page).to have_selector("img[src$='#{recipe.recipe_image.url}']")
      expect(page).to have_content(recipe.tip)
      recipe.ingredients.each do |ingredient|
        expect(page).to have_content(ingredient.name)
        expect(page).to have_content(ingredient.quantity)
      end
      recipe.instructions.each do |instruction|
        expect(page).to have_content(instruction.step)
        expect(page).to have_content(instruction.description)
      end
      expect(page).to have_content(recipe.work_title)
      expect(page).to have_content(recipe.work_author)
      expect(page).to have_selector("img[src$='#{recipe.work_image}']")
      expect(page).to have_content(recipe.work_price)
    end

    it "画像選択で古い画像が消え、新しい画像プレビューが表示されること", js: true do
      attach_file("料理画像", image_file_path("test_recipe_image.png"))
      expect(page).not_to have_css("#current-image")
      expect(page).to have_css("#new-image img")
    end

    it "無効な情報を入力するとエラーが表示されること" do
      fill_in "レシピタイトル", with: ""
      fill_in "作品名", with: ""
      fill_in "ポイント・コツ", with: ""
      fill_in "recipe[ingredients_attributes[0][name]]", with: ""
      fill_in "recipe[ingredients_attributes[0][quantity]]", with: ""
      fill_in "recipe[instructions_attributes[0][description]]", with: ""
      click_button "更新する"

      expect(page).to have_content("レシピタイトルを入力してください")
      expect(page).to have_content("作品名を入力してください")
      expect(page).to have_content("ポイント・コツを入力してください")
      expect(page).to have_content("材料名を入力してください")
      expect(page).to have_content("分量を入力してください")
      expect(page).to have_content("説明を入力してください")
    end

    it "追加ボタンで材料のフォームが追加されること", js: true do
      within(".ingredients-wrapper") do
        click_button "+追加"
      end

      expect(page).to have_field("recipe[ingredients_attributes][3][name]")
      expect(page).to have_field("recipe[ingredients_attributes][3][quantity]")
    end

    it "追加ボタンで手順のフォームが追加されること", js: true do
      within(".instructions-wrapper") do
        click_button "+追加"
      end

      expect(page).to have_field("recipe[instructions_attributes][3][description]")
    end

    it "削除ボタンを押すとレシピが削除されること" do
      click_link "削除"

      expect(current_path).to eq(profile_path(user))
      expect(page).not_to have_content(recipe.title)
    end

    it "ブラウザタブのタイトルが正しく表示されること" do
      expect(page).to have_title "レシピ編集 - 再現Kitchen"
    end
  end

  describe "レシピ検索" do
    let!(:recipe1) { create(:recipe, title: "レシピ1", work_name: "ab") }
    let!(:recipe2) { create(:recipe, title: "テスト2", work_name: "bc") }

    before { visit search_recipes_path }

    it "キーワードにマッチするレシピ情報が表示されること" do
      fill_in "keyword", with: "レシピ b"
      click_button "検索"
      expect(page).to have_content(recipe1.title)
      expect(page).to have_content(recipe1.work_name)
      expect(page).to have_selector("img[src$='#{recipe1.recipe_image.thumb.url}']")
      expect(page).to have_content(recipe1.user.name)
      expect(page).to have_selector("img[src$='#{recipe1.user.avatar.smaller.url}']")
      expect(page).not_to have_content(recipe2.title)
    end

    it "ブラウザタブのタイトルが正しく表示されること" do
      expect(page).to have_title "レシピ検索 - 再現Kitchen"
    end
  end
end
