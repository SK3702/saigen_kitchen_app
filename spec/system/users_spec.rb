require "rails_helper"

RSpec.describe "Users", type: :system do
  let(:user) { create(:user) }

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
      expect(page).to have_content("Eメールは不正な値です")
      expect(page).to have_content("パスワードは6文字以上で入力してください")
      expect(page).to have_content("パスワード（確認用）とパスワードの入力が一致しません")
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
      expect(page).to have_content("Eメールまたはパスワードが違います")
    end
  end

  describe "アカウント情報編集" do
    before do
      sign_in(user)
      visit profile_path(user)
      click_link "編集"
      expect(current_path).to eq edit_user_registration_path
    end

    it "正しい情報でアカウント情報を更新できること" do
      fill_in "ユーザーネーム", with: "updated"
      fill_in "Email", with: "test@updated.com"
      fill_in "自己紹介", with: "Hi."
      attach_file("アイコン", image_file_path("test_image.png"))
      click_button "更新する"

      expect(page).to have_content("アカウント情報を変更しました。")
      expect(user.reload.name).to eq("updated")
      expect(user.reload.email).to eq("test@updated.com")
    end

    it "不正な情報でアカウント情報の更新に失敗すること" do
      fill_in "ユーザーネーム", with: ""
      fill_in "Email", with: "invalid-email"
      attach_file("アイコン", image_file_path("invalid_image.txt"))
      click_button "更新する"

      expect(page).to have_content("ユーザーネームを入力してください")
      expect(page).to have_content("Eメールは不正な値です")
      expect(page).to have_content("許可されていない拡張子です")
    end
  end

  describe "ログアウト" do
    before do
      sign_in(user)
      visit root_path
      click_link "ログアウト"
    end

    it "ユーザーがログアウトできること" do
      expect(page).to have_content("ログアウトしました。")
      expect(page).to have_content("ログイン")
    end

    it "ログアウト後に保護されたページにアクセスできないこと" do
      visit profile_path(user)
      expect(current_path).to eq(new_user_session_path)
      expect(page).to have_content("ログインもしくはアカウント登録してください。")
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
