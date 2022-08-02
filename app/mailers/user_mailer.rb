class UserMailer < ApplicationMailer
  def new_user(user)
    @user = user
    @user_emails = User.with_role(:admin).distinct.pluck(:email)
    mail(to: @user_emails, subject: 'New registration')
  end
end
