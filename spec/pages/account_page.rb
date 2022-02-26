# frozen_string_literal: true

module AccountPage
  class New < SitePrism::Page
    set_url '/account'

    element :hi_user, "h5[id='hi-user']"
    element :logout_from_everywhere, "input[value='Log out from everywhere']"
  end
end
