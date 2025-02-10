require 'rails_helper'

RSpec.describe "Contacts", type: :request do
  let(:valid_params) do
    {
      contact: {
        name: "Test User",
        email: "test@example.com",
        subject: "Test Subject",
        message: "This is a test message.",
      },
    }
  end
  let(:invalid_params) do
    {
      contact: {
        name: "",
        email: "",
        subject: "",
        message: "",
      },
    }
  end

  describe "GET /contacts/new" do
    before { get new_contact_path }
    it "レスポンスが正常であること" do
      expect(response).to have_http_status(200)
    end

    it "お問い合わせフォームが含まれていること" do
      expect(response.body).to include("お問い合わせ")
      expect(response.body).to include("名前")
      expect(response.body).to include("メールアドレス")
      expect(response.body).to include("件名")
      expect(response.body).to include("お問い合わせ内容(1000文字以内)")
    end
  end

  describe "POST /contacts/confirm" do
    context "有効なパラメータの場合" do
      it "確認画面が含まれ、入力内容が含まれていること" do
        post confirm_contacts_path, params: valid_params
        expect(response).to have_http_status(200)
        expect(response.body).to include("Test User")
        expect(response.body).to include("test@example.com")
        expect(response.body).to include("Test Subject")
        expect(response.body).to include("This is a test message.")
      end
    end

    context "無効なパラメータの場合" do
      it "再びお問い合わせフォームが含まれていること" do
        post confirm_contacts_path, params: invalid_params
        expect(response).to have_http_status(200)
        expect(flash[:alert]).to include("を入力してください")
        expect(response.body).to include("お問い合わせ")
      end
    end
  end

  describe "POST /contacts/back" do
    it "入力画面に戻ると、入力内容が保持された状態でフォームが含まれていること" do
      post confirm_contacts_path, params: valid_params
      post back_contacts_path, params: valid_params
      expect(response).to have_http_status(200)
      expect(response.body).to include("Test User")
      expect(response.body).to include("test@example.com")
      expect(response.body).to include("Test Subject")
      expect(response.body).to include("This is a test message.")
    end
  end

  describe "POST /contacts" do
    context "有効なパラメータの場合" do
      it "お問い合わせが送信され、トップページにリダイレクトされること" do
        expect { post contacts_path, params: valid_params }.to change(Contact, :count).by(1)
        mail = ActionMailer::Base.deliveries.last
        expect(mail.to).to include(ENV['GOOGLE_MAIL_ADDRESS'])
        expect(mail.subject).to include("【お問い合わせ】")

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to include("お問い合わせが完了しました。")
      end
    end

    context "無効なパラメータの場合" do
      it "お問い合わせフォームが再び含まれていること" do
        expect { post contacts_path, params: invalid_params }.not_to change(Contact, :count)
        expect(response.body).to include("お問い合わせ")
      end
    end
  end
end
