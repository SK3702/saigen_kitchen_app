class ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def confirm
    @contact = Contact.new(contact_params)
    if @contact.invalid?
      flash[:alert] = @contact.errors.full_messages.join(", ")
      render :new
    end
  end

  def back
    @contact = Contact.new(contact_params)
    render :new
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      ContactMailer.send_mail(@contact).deliver_now
      redirect_to root_path
      flash[:notice] = "お問い合わせが完了しました。"
    else
      flash[:alert] = @contact.errors.full_messages.join(", ")
      render :new
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message)
  end
end
