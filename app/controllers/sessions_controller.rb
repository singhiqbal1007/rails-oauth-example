class SessionsController < ApplicationController
  before_action :redirect_if_authenticated, only: [:create, :new]
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
        remember(active_session) if params[:user][:remember_me] == "1"
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
  def new
  end
end
