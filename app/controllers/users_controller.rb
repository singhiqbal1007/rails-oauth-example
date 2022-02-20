# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[edit destroy update show]
  before_action :redirect_if_authenticated, only: %i[create new]

  # POST: sign up page
  def create
    @user = User.new(create_user_params)
    if @user.save
      token = @user.send_confirmation_email!

      # generate confirmation url
      url = edit_confirmation_url(token)
      redirect_to root_path, flash: { notice: I18n.t('check_your_email'), confirm_url: url }
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE: Delete user
  def destroy
    current_user.destroy
    reset_session
    redirect_to root_path, notice: 'Your account has been deleted.'
  end

  # GET: account page
  def edit
    @user = current_user
  end

  # GET: sign up page
  def new
    @user = User.new
  end

  # PUT: upgate account page
  def update
    @user = current_user
    @active_sessions = @user.active_sessions.order(created_at: :desc)
    if @user.authenticate(params[:user][:current_password])
      if @user.update(update_user_params)
        if params[:user][:unconfirmed_email].present?
          @user.send_confirmation_email!
          redirect_to root_path, flash: { notice: I18n.t('check_your_email') }
        else
          redirect_to root_path, notice: 'Account updated.'
        end
      else
        render :edit, status: :unprocessable_entity
      end
    else
      flash.now[:error] = 'Incorrect password'
      render :edit, status: :unprocessable_entity
    end
  end

  # GET: user account page
  def show
    @user = current_user
    @active_sessions = @user.active_sessions.order(created_at: :desc)
  end

  private

  def create_user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def update_user_params
    params.require(:user).permit(:current_password, :password, :password_confirmation, :unconfirmed_email)
  end
end
