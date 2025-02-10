require "rails_helper"

RSpec.describe Devise::Mailer, type: :mailer do
  describe "#reset_instructions" do
    let(:user) { create(:user) }
    let(:reset_token) do
      token = user.send_reset_password_instructions
      user.reload
      token
    end
    let(:mail) { Devise::Mailer.reset_password_instructions(user, reset_token) }

    it "正しい送信元が設定されていること" do
      expect(mail.from).to eq(["noreply@example.com"])
    end

    it "正しい送信先が設定されていること" do
      expect(mail.to).to eq([user.email])
    end

    it "正しい件名が設定されていること" do
      expect(mail.subject).to include("パスワードの再設定")
    end

    it "メール本文にパスワードリセットのリンクが含まれていること" do
      expect(mail.body.encoded).to include("パスワードの変更を受け付けました。以下のリンクから変更できます。")
    end
  end
end
