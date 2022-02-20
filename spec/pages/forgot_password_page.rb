# frozen_string_literal: true

module ForgotPasswordPage
  class New < SitePrism::Page
    set_url '/passwords/new'

    element :email_input, "input[id='email']"
    element :submit_button, "button[type='submit']"

    def reset_password(user)
      email_input.set user.email
      submit_button.click
    end
  end

  class Edit < SitePrism::Page
    set_url '/passwords{/token}/edit'

    element :password_input, "input[id='password']"
    element :password_confirmation_input, "input[id='password_confirmation']"
    element :submit_button, "button[type='submit']"

    def change_password(user)
      password_input.set user.password
      password_confirmation_input.set user.password_confirmation
      submit_button.click
    end
  end
end
