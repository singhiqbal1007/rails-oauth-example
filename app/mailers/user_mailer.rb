# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default from: User::MAILER_FROM_EMAIL

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.confirmation.subject
  #

  # send mail to confirm user email
  def confirmation(user, confirmation_token)
    @user = user
    @confirmation_token = confirmation_token

    # we are not sending mail actual mail in the demo
    # mail to: @user.confirmable_email, subject: "Confirmation Instructions"
  end

  # send mail to reset password
  def password_reset(user, password_reset_token)
    @user = user
    @password_reset_token = password_reset_token

    # we are not sending mail actual mail in the demo
    # mail to: @user.email, subject: "Password Reset Instructions"
  end
end
