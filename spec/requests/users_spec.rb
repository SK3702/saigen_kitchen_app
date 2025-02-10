require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:user) { create(:user) }
  let!(:another_user) { create(:user) }

  describe "新規登録" do
    describe "GET /users/sign_up" do
      before { get new_user_registration_path }
      it "レスポンスが正常であること" do
        expect(response).to have_http_status(200)
      end

      it "新規登録フォームが含まれていること" do
        expect(response.body).to include("新規登録", "ユーザーネーム", "Email", "パスワード(6文字以上)", "パスワード(確認用)")
      end
    end

    describe "POST /users" do
      context "有効なパラメータの場合" do
        it "ユーザーが作成される" do
          expect { post user_registration_path, params: { user: attributes_for(:user) } }.to change(User, :count).by(1)
          expect(response).to redirect_to(root_path)
        end
      end

      context "無効なパラメータの場合" do
        it "ユーザーが作成されない" do
          expect { post user_registration_path, params: { user: { name: "", email: "invalid", password: "short" } } }.
            not_to change(User, :count)
          expect(response.body).to include("ユーザーネームを入力してください", "メールアドレスは不正な値です", "パスワードは6文字以上で入力してください")
        end
      end
    end
  end

  describe "ログイン" do
    describe "GET /users/sign_in" do
      before { get new_user_session_path }
      it "レスポンスが正常であること" do
        expect(response).to have_http_status(200)
      end

      it "ログインフォームが含まれていること" do
        expect(response.body).to include("ログイン", "Email", "パスワード(6文字以上)")
      end
    end

    describe "POST /users/sign_in" do
      context "有効なパラメータの場合" do
        it "ログインに成功する" do
          post user_session_path, params: { user: { email: user.email, password: user.password } }
          expect(response).to redirect_to(root_path)
        end
      end

      context "無効なパラメータの場合" do
        it "ログインに失敗する" do
          post user_session_path, params: { user: { email: user.email, password: "wrong_password" } }
          expect(response.body).to include("メールアドレスまたはパスワードが違います")
        end
      end
    end
  end

  describe "プロフィール" do
    describe "GET /profiles/:id" do
      before do
        sign_in user
        get profile_path(user)
      end

      it "レスポンスが正常であること" do
        expect(response).to have_http_status(200)
      end

      it "userのアカウント情報が含まれており、another_userのアカウント情報が含まれていないこと" do
        expect(response.body).to include(user.name, user.email, user.bio)
        expect(response.body).to include('src="/assets/default')
        expect(response.body).not_to include another_user.email
      end
    end
  end

  describe "アカウント情報編集" do
    before do
      sign_in user
      get edit_user_registration_path
    end

    describe "GET/ users/edit" do
      it "レスポンスが正常であること" do
        expect(response).to have_http_status(200)
      end

      it "アカウント情報編集フォームが含まれていること" do
        expect(response.body).to include("アカウント情報編集", "ユーザーネーム", "Email", "自己紹介", "アイコン", "更新する")
      end

      context "未ログインユーザーの場合" do
        it '未ログインユーザはログインページにリダイレクトされること' do
          sign_out user
          get edit_user_registration_path
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end

    describe "PATCH /users" do
      context "有効なパラメータの場合" do
        it "アカウント情報更新に成功すること" do
          updated_image = Rack::Test::UploadedFile.new(image_file_path("test_image.png"), "image/png")
          patch user_registration_path,
            params: { user: { name: "updated", email: "test@updated.com", bio: "Updated.", avatar: updated_image } }
          expect(response).to redirect_to(profile_path(user))
        end
      end

      context "無効なパラメータの場合" do
        it "アカウント情報更新に失敗すること" do
          invalid_image = Rack::Test::UploadedFile.new(image_file_path("invalid_image.txt"), "text/plain")
          patch user_registration_path, params: { user: { name: "", email: "invalid", avatar: invalid_image } }
          expect(response.body).to include("ユーザーネームを入力してください", "メールアドレスは不正な値です", "アイコン画像は許可されていない拡張子です")
        end
      end

      context "未ログインユーザーの場合" do
        it '未ログインユーザはログインページにリダイレクトされること' do
          sign_out user
          patch user_registration_path, params: { user: { name: "updated" } }
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end

  describe "パスワード変更" do
    let!(:test_user) { create(:user, email: "test@example.com") }
    let(:reset_token) do
      token = test_user.send_reset_password_instructions
      test_user.reload
      token
    end

    describe "GET /users/password/new" do
      before do
        get new_user_password_path
      end

      it "レスポンスが正常であること" do
        expect(response).to have_http_status(200)
      end

      it "パスワード変更フォームが含まれていること" do
        expect(response.body).to include("ご利用中のメールアドレスをご入力ください")
        expect(response.body).to include("Email")
      end
    end

    describe "POST /user/password" do
      let(:valid_params) { { user: { email: test_user.email } } }
      let(:invalid_params) { { user: { email: "non@exist.com" } } }

      context "有効なパラメータの場合" do
        it "パスワードリセットのメールが送信され、ログインページにリダイレクトされること" do
          ActionMailer::Base.deliveries.clear
          post user_password_path, params: valid_params
          expect(response).to redirect_to(new_user_session_path)
          expect(ActionMailer::Base.deliveries.count).to eq(1)
        end
      end

      context "無効なパラメーターの場合" do
        it "パスワードリセットのメールが送信されないこと" do
          ActionMailer::Base.deliveries.clear
          post user_password_path, params: invalid_params
          expect(ActionMailer::Base.deliveries.count).to eq(0)
          expect(response.body).to include("は見つかりませんでした。")
        end
      end
    end

    describe "GET /users/password/edit" do
      before do
        get edit_user_password_path, params: { reset_password_token: reset_token }
      end

      it "レスポンスが正常であること" do
        expect(response).to have_http_status(200)
      end

      it "パスワード変更フォームが含まれていること" do
        expect(response.body).to include("パスワード再設定")
        expect(response.body).to include("新しいパスワード")
      end
    end

    describe "PATCH /users/pasword" do
      let(:valid_params) do
        { user: { password: "new_password", password_confirmation: "new_password", reset_password_token: reset_token } }
      end
      let(:invalid_params) { { user: { password: "short", password_confirmation: "short", reset_password_token: reset_token } } }

      context "有効なパラメーターの場合" do
        it "パスワードが変更できて、トップページにリダイレクトされること" do
          patch user_password_path, params: valid_params
          expect(response).to redirect_to(root_path)
        end
      end

      context "無効なパラメーターの場合" do
        it "パスワードが変更できないこと" do
          patch user_password_path, params: invalid_params
          expect(response.body).to include("6文字以上で入力してください")
        end
      end
    end
  end

  describe "ログアウト" do
    describe "DELETE /users/sign_out" do
      it "アカウントがログアウトできること" do
        sign_in user
        expect { delete destroy_user_session_path }.to change(User, :count).by(0)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "アカウント削除" do
    describe "DELETE /users" do
      it "アカウントが削除されること" do
        sign_in user
        expect { delete user_registration_path }.to change(User, :count).by(-1)
        expect(response).to redirect_to(root_path)
      end

      context "未ログインユーザーの場合" do
        it '未ログインユーザはログインページにリダイレクトされること' do
          sign_out user
          delete user_registration_path
          expect(response).to redirect_to(new_user_session_path)
        end
      end
    end
  end
end
