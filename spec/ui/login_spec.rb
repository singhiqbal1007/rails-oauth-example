require 'rails_helper'

feature 'Basic login', type: :feature, js: true do
  given!(:login_page) { SessionPage::New.new }
  given!(:account_page) { AccountPage::New.new }

  given!(:incorrect_user) { build(:user, email: 'wrong@wrong.com', password: 'wrong' ) }
  given!(:confirmed_user) { create(:user, :confirmed_now, :with_password_confirmation) }
  given!(:unconfirmed_user) { create(:user) }

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

  scenario 'Login confirmed user' do
    login_page.load
    login_page.log_in(confirmed_user)
    expect(account_page.heading).to have_text 'Current Logins'
    account_page.logout_from_everywhere.click
    expect(login_page).to have_email_input
  end

end
