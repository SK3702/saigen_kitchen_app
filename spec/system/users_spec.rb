require "rails_helper"

RSpec.describe "Users", type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:recipes) do
    create_list(:recipe, 2, user_id: user.id).
      each_with_index do |recipe, index|
        recipe.update(created_at: index.day.ago, title: "test_recipe#{index}")
      end
  end
  let!(:other_recipe) { create(:recipe, title: "other_title", user_id: other_user.id) }

  describe "ユーザー新規登録" do
    before do
      visit new_user_registration_path
    end

    it "正しい情報を入力すると登録できること" do
      fill_in "ユーザーネーム", with: "test"
      fill_in "Email", with: "test@example.com"
      fill_in "パスワード(6文字以上)", with: "testuser"
      fill_in "パスワード(確認用)", with: "testuser"
      click_button "新規登録"

      expect(current_path).to eq root_path
      expect(page).to have_content "アカウント登録が完了しました"
    end

    it "不正な情報を入力すると登録に失敗すること" do
      fill_in "ユーザーネーム", with: ""
      fill_in "Email", with: "invalid-email"
      fill_in "パスワード(6文字以上)", with: "123"
      fill_in "パスワード(確認用)", with: "456"
      click_button "新規登録"

      expect(current_path).to eq user_registration_path
      expect(page).to have_content("エラーが発生したため ユーザー は保存されませんでした。")
      expect(page).to have_content("ユーザーネームを入力してください")
      expect(page).to have_content("メールアドレスは不正な値です")
      expect(page).to have_content("パスワードは6文字以上で入力してください")
      expect(page).to have_content("パスワード（確認用）とパスワードの入力が一致しません")
    end

    it "ブラウザタブのタイトルが正しく表示されること" do
      expect(page).to have_title "新規登録 - 再現Kitchen"
    end
  end

  describe "ログイン" do
    before do
      visit new_user_session_path
    end

    it "正しい情報を入力するとログインできること" do
      fill_in "Email", with: user.email
      fill_in "パスワード", with: user.password
      click_button "ログイン"

      expect(current_path).to eq root_path
      expect(page).to have_content("ログインしました")
      expect(page).to have_content(user.name)
    end

    it "不正な情報を入力するとログインに失敗すること" do
      fill_in "Email", with: user.email
      fill_in "パスワード", with: "wrongpassword"
      click_button "ログイン"

      expect(current_path).to eq new_user_session_path
      expect(page).to have_content("メールアドレスまたはパスワードが違います")
    end

    it "ブラウザタブのタイトルが正しく表示されること" do
      expect(page).to have_title "ログイン - 再現Kitchen"
    end
  end

  describe "プロフィールページ" do
    before do
      sign_in user
      visit profile_path(user)
    end

    it "アカウント情報がプロフィールに表示されていること" do
      expect(page).to have_content(user.name)
      expect(page).to have_content(user.email)
      expect(page).to have_content(user.bio)
      expect(page).to have_selector("img[src$='#{user.avatar.url}']")
    end

    it "ユーザーの投稿したレシピが最新のレシピから順に表示されていること" do
      display_recipes = all(".recipe-link")

      expect(display_recipes.first).to have_content(recipes[0].title)
      expect(display_recipes.last).to have_content(recipes[1].title)
    end

    it "ユーザーの投稿したレシピ情報のみが表示されており、レシピ情報押下でレシピページへ遷移すること" do
      recipes.each do |recipe|
        expect(page).to have_selector("img[src$='#{recipe.recipe_image.thumb.url}']")
        expect(page).to have_link(recipe.title, href: recipe_path(recipe.id))
      end
      expect(page).not_to have_content(other_recipe.title)

      all(".recipe-link").first.click
      expect(current_path).to eq recipe_path(recipes[0].id)
    end

    it "ログインユーザーが自分のアカウント情報を編集できるリンクがあり、クリックで遷移すること" do
      click_link "編集"
      expect(current_path).to eq(edit_user_registration_path)
    end

    context "他のユーザーの場合" do
      before do
        sign_in other_user
        visit profile_path(user.id)
      end

      it "編集ボタンが表示されないこと" do
        expect(page).not_to have_link("編集", href: edit_user_registration_path(user))
      end

      it "emailが表示されないこと" do
        expect(page).not_to have_content(user.email)
      end
    end

    it "ブラウザタブのタイトルが正しく表示されること" do
      expect(page).to have_title "#{user.name} - 再現Kitchen"
    end
  end

  describe "アカウント情報編集" do
    before do
      sign_in(user)
      visit profile_path(user)
      click_link "編集"
      expect(current_path).to eq edit_user_registration_path
    end

    it "現在のレシピ情報が編集フォームに表示されていること" do
      fill_in "ユーザーネーム", with: user.name
      fill_in "Email", with: user.email
      fill_in "自己紹介", with: user.bio
      expect(page).to have_selector("img[src$='#{user.avatar.url}']")
    end

    it "正しい情報でアカウント情報を更新でき、表示されること" do
      fill_in "ユーザーネーム", with: "updated"
      fill_in "Email", with: "test@updated.com"
      fill_in "自己紹介", with: "Hi."
      attach_file("アイコン", image_file_path("test_image.png"))
      click_button "更新する"

      expect(page).to have_content("アカウント情報を変更しました。")

      visit profile_path(user)
      user.reload
      expect(page).to have_content(user.name)
      expect(page).to have_content(user.email)
      expect(page).to have_content(user.bio)
      expect(page).to have_selector("img[src$='#{user.avatar.url}']")
    end

    it "不正な情報でアカウント情報の更新に失敗すること" do
      fill_in "ユーザーネーム", with: ""
      fill_in "Email", with: "invalid-email"
      attach_file("アイコン", image_file_path("invalid_image.txt"))
      click_button "更新する"

      expect(page).to have_content("ユーザーネームを入力してください")
      expect(page).to have_content("メールアドレスは不正な値です")
      expect(page).to have_content("許可されていない拡張子です")
    end

    it "ブラウザタブのタイトルが正しく表示されること" do
      expect(page).to have_title "プロフィール編集 - 再現Kitchen"
    end
  end

  describe "ログアウト" do
    it "ユーザーがログアウトできること" do
      sign_in(user)
      visit root_path
      click_link "ログアウト"
      expect(page).to have_content("ログアウトしました。")
      expect(page).to have_content("ログイン")
    end
  end

  describe "アカウント削除" do
    it "アカウントを削除できること" do
      sign_in(user)
      visit edit_user_registration_path

      click_link "アカウントを削除する"
      expect(page).to have_content("アカウントを削除しました。またのご利用をお待ちしております。")
      expect(User.exists?(user.id)).to be_falsey
    end
  end
end
