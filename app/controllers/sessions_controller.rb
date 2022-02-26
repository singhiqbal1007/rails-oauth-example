# frozen_string_literal: true

class SessionsController < ApplicationController
  include OidcLoginHelper
  
  before_action :redirect_if_authenticated, only: %i[create new]
  before_action :authenticate_user!, only: [:destroy]

  # POST: create session i.e post request on login form
  def create
    # find user from email and password
    @user = User.authenticate_by(email: params[:user][:email].downcase, password: params[:user][:password])
    # if user exists
    if @user
      # if user email is not confirmed show alert
      if @user.unconfirmed?
        redirect_to login_path, alert: I18n.t('login_failed')
      else
        # get user return to path from session
        after_login_path = session[:user_return_to] || account_path
        # login the user
        active_session = login @user
        # save session in cookies if remember me is checked
        remember(active_session) if params[:user][:remember_me] == '1'
        # redirect to the after_login_path
        redirect_to after_login_path
      end
    # show alert if user does not exists
    else
      flash.now[:alert] = I18n.t('login_failed')
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE: delete session via logout
  def destroy
    forget_active_session
    logout
    redirect_to root_path
  end

  # GET: login page
  def new; end


  # === OIDC LOGIN ===
  #### Step 1: https://openid.net/specs/openid-connect-basic-1_0.html#AuthenticationRequest
  # Generate Authorization URL with scope=email, prompt=consent, redirect_uri=callback_url and response_type=code
  #
  #### Step 2: https://openid.net/specs/openid-connect-basic-1_0.html#CodeRequest
  # Send the Authentication Request
  #
  #### Step 3: https://openid.net/specs/openid-connect-basic-1_0.html#Authenticates
  # Authorization Server Authenticates End-User
  #
  #### Step 4: https://openid.net/specs/openid-connect-basic-1_0.html#Consent
  # User gets consent
  def oidc_login
    client = GoogleOidc.client(root_url)
    session[:state] = SecureRandom.hex(16)

    # generate the authorization_uri
    auth_uri = client.authorization_uri(
      scope: [:openid, :email],
      state: session[:state],
      prompt: 'consent',
      response_type: 'code'
    )
    redirect_to auth_uri
  end


  #### Step 5: https://openid.net/specs/openid-connect-basic-1_0.html#CodeResponse
  # Get the code provided the Authentication Server
  #
  #### Step 6: https://openid.net/specs/openid-connect-basic-1_0.html#ObtainingTokens
  # Obtain ID token
  #
  # Step 7: https://openid.net/specs/openid-connect-basic-1_0.html#IDToken
  # Get User email from Id Token
  #
  # Step 8: Login the user with the email
  def oauth_callback
    client = GoogleOidc.client(root_url)

    # get the authorization code from parameters
    client.authorization_code = params[:code]

    # request for token
    token = client.access_token!

    # if code is correct, token will be received
    if token
      hash = JSON::JWT.decode(token.id_token, :skip_verification)
      email = hash['email']
      if email.present?
        user = User.find_by(email: email)
        if user
          login user
          redirect_to account_path
        else
          flash.now[:alert] = I18n.t('oauth_login_failed')
          render :new, status: :unprocessable_entity
        end
      else
        redirect_to root_url,  alert: I18n.t('oauth_login_error')
      end
    else
      # redirect user to homepage in case of incorrect code
      redirect_to root_url
    end
    
  end
end
