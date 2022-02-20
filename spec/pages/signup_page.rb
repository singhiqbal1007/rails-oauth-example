# frozen_string_literal: true

module SignupPage
  class New < SitePrism::Page
    set_url '/sign_up'

    element :email_input, "input[id='email']"
    element :password_input, "input[id='password']"
    element :password_confirmation_input, "input[id='password_confirmation']"
    element :sign_up_button, "button[type='submit']"

    def sign_up(user)
      email_input.set user.email
      password_input.set user.password
      password_confirmation_input.set user.password_confirmation
      sign_up_button.click
    end
  end
end
