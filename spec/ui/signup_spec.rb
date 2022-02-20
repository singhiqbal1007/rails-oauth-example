# frozen_string_literal: true

require 'rails_helper'

feature 'Basic Signup', type: :feature, js: true do
  given!(:login_page) { SessionPage::New.new }
  given!(:signup_page) { SignupPage::New.new }
  given!(:account_page) { AccountPage::New.new }

  given!(:new_confirmed_user) { build(:user, :with_password_confirmation) }
  given!(:new_unconfirmed_user) { build(:user, :with_password_confirmation) }

  scenario 'Signup user, confirm and login' do
    signup_page.load
    signup_page.sign_up(new_confirmed_user)
    login_page.email_link.click
    expect(account_page.heading).to have_text 'Current Logins'
    account_page.logout_from_everywhere.click
    expect(login_page).to have_email_input
  end

  scenario 'Signup user and login without confirming' do
    signup_page.load
    signup_page.sign_up(new_unconfirmed_user)
    login_page.log_in(new_unconfirmed_user)
    expect(login_page.alert).to have_text I18n.t('login_failed')
  end
end
