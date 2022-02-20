# frozen_string_literal: true

module ConfirmationPage
  class New < SitePrism::Page
    set_url '/confirmations/new'

    element :email_input, "input[id='email']"
    element :submit_button, "button[type='submit']"
    element :alert, "div[role='alert']"

    def send_confirmation_link(user)
      email_input.set user.email
      submit_button.click
    end
  end
end
