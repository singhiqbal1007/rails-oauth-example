# frozen_string_literal: true

require 'rails_helper'

feature 'Basic login', type: :feature, js: true do
  given!(:login_page) { SessionPage::New.new }
  given!(:account_page) { AccountPage::New.new }

  given!(:incorrect_user) { build(:user, email: 'wrong@wrong.com', password: 'wrong') }
  given!(:confirmed_user) { create(:user, :confirmed_now, :with_password_confirmation) }
  given!(:unconfirmed_user) { create(:user) }
  given!(:oidc_user) { create(:user, :oidc) }

  scenario 'Login incorrect user' do
    login_page.load
    login_page.log_in(incorrect_user)
    expect(login_page.alert).to have_text I18n.t('login_failed')
  end

  scenario 'Login unconfirmed user' do
    login_page.load
    login_page.log_in(unconfirmed_user)
    expect(login_page.alert).to have_text I18n.t('login_failed')
  end

  scenario 'OIDC User login via login form' do
    login_page.load
    oidc_user.password = 'random'
    login_page.log_in(oidc_user)
    expect(login_page.alert).to have_text I18n.t('login_failed')
  end

  scenario 'Login confirmed user' do
    login_page.load
    login_page.log_in(confirmed_user)
    expect(account_page.hi_user).to have_text "Hi #{confirmed_user.email}"
    account_page.logout_from_everywhere.click
    expect(login_page).to have_email_input
  end
end
