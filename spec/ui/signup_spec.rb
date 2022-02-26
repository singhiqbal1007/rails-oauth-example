# frozen_string_literal: true

require 'rails_helper'

feature 'Basic Signup', type: :feature, js: true do
  given!(:login_page) { SessionPage::New.new }
  given!(:signup_page) { SignupPage::New.new }
  given!(:account_page) { AccountPage::New.new }

  given!(:new_confirmed_user) { build(:user, :with_password_confirmation) }
  given!(:user_with_short_password) { build(:user, password: '12', password_confirmation: '12') }
  given!(:new_unconfirmed_user) { build(:user, :with_password_confirmation) }
  given!(:confirmed_user) { create(:user, :confirmed_now, :with_password_confirmation) }
  given!(:unconfirmed_user) { create(:user, :with_password_confirmation) }

  scenario 'Signup with already present confirmed email' do
    signup_page.load
    signup_page.sign_up(confirmed_user)
    expect(signup_page.alert).to have_text 'Email has already been taken'
  end

  scenario 'Signup with already present unconfirmed email' do
    signup_page.load
    signup_page.sign_up(unconfirmed_user)
    expect(signup_page.alert).to have_text 'Email has already been taken'
  end

  scenario 'Signup with wrong confirmation password' do
    signup_page.load
    unconfirmed_user.email = 'random@email.com'
    unconfirmed_user.password_confirmation = 'wrong'
    signup_page.sign_up(unconfirmed_user)
    expect(signup_page.alert).to have_text "Password confirmation doesn't match Password"
  end

  scenario 'Signup with password less than 3 char' do
    signup_page.load
    signup_page.sign_up(user_with_short_password)
    expect(signup_page.alert).to have_text 'Password is too short (minimum is 3 characters)'
  end

  scenario 'Signup user, confirm and login' do
    signup_page.load
    signup_page.sign_up(new_confirmed_user)
    login_page.email_link.click
    expect(account_page.hi_user).to have_text "Hi #{new_confirmed_user.email}"
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
