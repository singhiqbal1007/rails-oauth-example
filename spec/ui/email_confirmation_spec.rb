# frozen_string_literal: true

require 'rails_helper'

feature 'Send Confirmation Link', type: :feature, js: true do
  given!(:login_page) { SessionPage::New.new }
  given!(:account_page) { AccountPage::New.new }
  given!(:forgot_password_new_page) { ForgotPasswordPage::New.new }
  given!(:forgot_password_edit_page) { ForgotPasswordPage::Edit.new }
  given!(:confirmation_page) { ConfirmationPage::New.new }

  given!(:incorrect_user) { build(:user, email: 'wrong@wrong.com') }
  given!(:unconfirmed_user) { create(:user) }
  given!(:confirmed_user) { create(:user, :confirmed_now, :with_password_confirmation) }

  scenario 'Send Confirmation Link for incorrect user' do
    confirmation_page.load
    confirmation_page.send_confirmation_link(incorrect_user)
    expect(confirmation_page.alert).to have_text I18n.t('confirmation_email_wrong')
  end

  scenario 'Send Confirmation Link for confirmed user' do
    confirmation_page.load
    confirmation_page.send_confirmation_link(confirmed_user)
    expect(confirmation_page.alert).to have_text I18n.t('confirmation_email_wrong')
  end

  scenario 'Send Confirmation Link for unconfirmed user' do
    # load confirmation page
    confirmation_page.load

    # send confirmation link
    confirmation_page.send_confirmation_link(unconfirmed_user)

    # click on confirmation link
    login_page.email_link.click

    # logout
    expect(account_page.hi_user).to have_text "Hi #{unconfirmed_user.email}"
    account_page.logout_from_everywhere.click
    expect(login_page).to have_email_input
  end
end
