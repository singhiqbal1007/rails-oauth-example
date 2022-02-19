require 'rails_helper'

feature 'Basic login', type: :feature, js: true do
  given!(:login_page) { SessionPage::New.new }
  given!(:account_page) { AccountPage::New.new }
  given!(:confirmed_user) { create(:user, :confirmed_now, :with_password_confirmation) }

  scenario 'basic login' do
    login_page.load
    login_page.log_in(confirmed_user)
    expect(account_page.heading).to have_text 'Current Logins'
  end

end
