require 'rails_helper'

feature 'Basic login', type: :feature, js: true, users: true do
  given!(:login_page) { SessionPage::New.new }
  # given!(:unconfirmed_user) { create(:user) }

  scenario 'basic login' do
    login_page.load
  end

end
