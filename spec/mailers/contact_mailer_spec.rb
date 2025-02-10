require "rails_helper"

RSpec.describe ContactMailer, type: :mailer do
  describe "#send_mail" do
    let(:contact) { build(:contact) }
    let(:mail) { ContactMailer.send_mail(contact) }

    it "正しい件名が設定されていること" do
      expect(mail.subject).to eq("【お問い合わせ】#{contact.subject}")
    end

    it "正しい送信先が設定されていること" do
      expect(mail.to).to eq([ENV['GOOGLE_MAIL_ADDRESS']])
    end

    it "メール本文に名前、メールアドレス、件名、問い合わせ内容が含まれていること" do
      expect(mail.body.encoded).to include(contact.name)
      expect(mail.body.encoded).to include(contact.email)
      expect(mail.body.encoded).to include(contact.subject)
      expect(mail.body.encoded).to include(contact.message)
    end
  end
end
