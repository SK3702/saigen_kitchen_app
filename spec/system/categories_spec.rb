require "rails_helper"

RSpec.describe "Categories", type: :system do
  let(:category) { create(:category, name: "マンガ") }
  let!(:other_category) { create(:category, name: "アニメ") }
  let!(:manga_recipes) do
    create_list(:recipe, 2, category_id: category.id).
      each_with_index do |recipe, index|
        recipe.update(created_at: index.day.ago)
      end
  end
  let!(:anime_recipe) { create(:recipe, title: "タイトル１", category_id: other_category.id) }

  before { visit category_path(category.id)}

  it "サイドバーに全てのカテゴリー名が表示され、選択しているカテゴリー以外のカテゴリー名にリンクがあること" do
    within(".nav") do
      expect(page).to have_content(category.name)
      expect(page).to have_content(other_category.name)
      expect(page).to have_link(other_category.name, href: category_path(other_category.id))
      expect(page).not_to have_link(category.name, href: category_path(category.id))
    end
  end

  it "他のカテゴリーリンクをクリックするとそのカテゴリーのページに遷移すること" do
    within(".nav") do
      click_link other_category.name
    end
    expect(page).to have_content(other_category.name)
  end

  it "メインセクションに選択したカテゴリー名が表示されること" do
    within(".category-recipes-area") do
      expect(page).to have_content(category.name)
    end
  end

  it "カテゴリーに属するレシピの情報のみが表示されること" do
    manga_recipes.each do |recipe|
      expect(page).to have_selector("img[src$='#{recipe.recipe_image.thumb.url}']")
      expect(page).to have_link(recipe.title, href: recipe_path(recipe.id))
      expect(page).to have_link(recipe.work_name, href: recipe_path(recipe.id))
      expect(page).to have_link(recipe.user.name, href: profile_path(recipe.user.id))
      expect(page).to have_css("a[href='#{profile_path(recipe.user.id)}'] img[src$='#{recipe.user.avatar.small.url}']")
    end
    expect(page).not_to have_content(anime_recipe.title)
  end

  it "最新のレシピから順に並んでいること" do
    display_recipes = all(".recipe-link")

    expect(display_recipes.first).to have_content(manga_recipes[0].title)
    expect(display_recipes.last).to have_content(manga_recipes[1].title)
  end

  it "レシピ情報押下でレシピページへ遷移すること" do
    all('.recipe-link').first.click
    expect(current_path).to eq recipe_path(manga_recipes[0].id)
  end

  it "ユーザー情報押下でプロフィールページへ遷移すること" do
    all('.user-link').first.click
    expect(current_path).to eq profile_path(manga_recipes[0].user.id)
  end
end
