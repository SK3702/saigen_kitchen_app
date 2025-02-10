class ContactMailer < ApplicationMailer
  def send_mail(contact)
    @contact = contact
    mail to:   ENV['GOOGLE_MAIL_ADDRESS'], subject: '【お問い合わせ】' + @contact.subject
  end
end
