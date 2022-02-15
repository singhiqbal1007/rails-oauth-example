# The Authentication Concern provides an interface for logging the user in and out.
# We load it into the ApplicationController so that it will be used across the whole application.
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :current_user
    helper_method :current_user
    helper_method :user_signed_in?
  end

  # The authenticate_user! method can be called to ensure
  # that an anonymous user cannot access a page that requires a user to be logged in.
  def authenticate_user!
    store_location
    redirect_to login_path, alert: I18n.t('access_denied') unless user_signed_in?
  end

  def login(user)
    # The reset_session method resets the session to account for session fixation
    # so if there is session fixed in the browser it will be removed
    # and new session will be created everytime login is called
    # https://guides.rubyonrails.org/security.html#session-fixation
    reset_session

    # We set the user's ID in the session so that we can have access to the user across requests.
    # The user's ID won't be stored in plain text.
    # The cookie data is cryptographically signed to make it tamper-proof.
    # And it is also encrypted so anyone with access to it can't read its contents.
    active_session = user.active_sessions.create!(user_agent: request.user_agent, ip_address: request.ip)
    session[:current_active_session_id] = active_session.id

    active_session
  end

  def forget_active_session
    cookies.delete :remember_token
  end

  # The logout method simply resets the session.
  def logout
    active_session = ActiveSession.find_by(id: session[:current_active_session_id])
    reset_session
    active_session.destroy! if active_session.present?
  end

  # The redirect_if_authenticated method checks to see if the user is logged in.
  # If they are, they'll be redirected to the root_path.
  # This will be useful on pages an authenticated user should not be able to access, such as the login page.
  def redirect_if_authenticated
    redirect_to account_path if user_signed_in?
  end

  # save session in cookies if remember me is checked
  def remember(active_session)
    cookies.permanent.encrypted[:remember_token] = active_session.remember_token
  end

  private

  # The current_user method returns a User and sets it as the user on the Current class we created.
  # We use memoization to avoid fetching the User each time we call the method.
  # We call the before_action filter so that we have access to the current user before each request.
  # We also add this as a helper_method so that we have access to current_user in the views.
  def current_user
    # check if session is active
    Current.user = if session[:current_active_session_id].present?
                     # get the user for the session
                     ActiveSession.find_by(id: session[:current_active_session_id])&.user
                   elsif cookies.permanent.encrypted[:remember_token].present?
                     # get session from cookies
                     curr_session = ActiveSession.find_by(remember_token: cookies.permanent.encrypted[:remember_token])
                     # store session id
                     session[:current_active_session_id] = curr_session&.id
                     ActiveSession.find_by(id: curr_session.id)&.user
                   end
  end

  # The user_signed_in? method simply returns true or false depending on whether the user is signed in or not.
  # This is helpful for conditionally rendering items in views.
  def user_signed_in?
    Current.user.present?
  end

  # store the user path in the session
  # so when user logs in we redirect to that path
  def store_location
    session[:user_return_to] = request.original_url if request.get? && request.local?
  end
end
