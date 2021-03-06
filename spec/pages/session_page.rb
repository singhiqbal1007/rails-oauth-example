# frozen_string_literal: true

module SessionPage
  class New < SitePrism::Page
    set_url '/login'

    element :email_input, "input[id='email']"
    element :password_input, "input[id='password']"
    element :remember_me_checkbox, "input[id='user_remember_me']"
    element :sign_in_button, "button[id='sign-in']"
    element :alert, "div[role='alert']"
    element :email_link, "a[id='email_link']"

    def log_in(user)
      email_input.set user.email
      password_input.set user.password
      sign_in_button.click
    end
  end
end
