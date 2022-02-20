require 'rails_helper'

feature 'Forgot Password', type: :feature, js: true do
  given!(:login_page) { SessionPage::New.new }
  given!(:account_page) { AccountPage::New.new }
  given!(:forgot_password_new_page) { ForgotPasswordPage::New.new }
  given!(:forgot_password_edit_page) { ForgotPasswordPage::Edit.new }
  given!(:confirmation_page) { ConfirmationPage::New.new }

  given!(:incorrect_user) { build(:user, email: 'wrong@wrong.com' ) }
  given!(:confirmed_user) { create(:user, :confirmed_now, :with_password_confirmation) }
  given!(:unconfirmed_user) { create(:user) }

  scenario 'Reset Password of incorrect user' do
    forgot_password_new_page.load
    forgot_password_new_page.reset_password(incorrect_user)
    expect(login_page.alert).to have_text I18n.t('email_does_not_exists')
  end

  scenario 'Reset Password of confirmed user' do
    # load forgot password page
    forgot_password_new_page.load

    # send reset password link
    forgot_password_new_page.reset_password(confirmed_user)

    # click on reset password reset link
    login_page.email_link.click

    # set new password
    confirmed_user.password = 'new_password'
    confirmed_user.password_confirmation = 'new_password'
    forgot_password_edit_page.change_password(confirmed_user)

    # login with new password
    login_page.log_in(confirmed_user)
    expect(account_page.heading).to have_text 'Current Logins'
    account_page.logout_from_everywhere.click
    expect(login_page).to have_email_input
  end

  scenario 'Reset Password of unconfirmed user' do
    # load forgot password page
    forgot_password_new_page.load

    # send reset password link
    forgot_password_new_page.reset_password(unconfirmed_user)

    # verify alert
    expect(confirmation_page.alert).to have_text I18n.t('unconfirmed_email')

    # send confirmation link
    confirmation_page.send_confirmation_link(unconfirmed_user)

    # click on confirmation link
    login_page.email_link.click

    # logout
    expect(account_page.heading).to have_text 'Current Logins'
    account_page.logout_from_everywhere.click
    expect(login_page).to have_email_input
  end
end
