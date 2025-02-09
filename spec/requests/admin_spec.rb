require 'rails_helper'

RSpec.describe "管理者機能", type: :request do
  describe "Get /admin" do
    let(:admin_user) { create(:user, admin: true) }
    let(:user) { create(:user, admin: false) }

    context "管理者ユーザーの場合" do
      it "管理者ページにアクセスでき、レスポンスが正常であること" do
        sign_in admin_user
        get rails_admin_path
        expect(response).to have_http_status(200)
      end
    end

    context "管理者ユーザー以外の場合" do
      it "一般ユーザーは管理者ページにアクセスできず、トップページにリダイレクトされること" do
        sign_in user
        get rails_admin_path
        expect(response).to redirect_to("/")
        expect(flash[:alert]).to include("アクセス権限がありません。")
      end

      it "未ログインユーザーは管理者ページにアクセスできず、ログインページにリダイレクトされる" do
        get rails_admin_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
