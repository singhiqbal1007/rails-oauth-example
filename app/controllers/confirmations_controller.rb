class ConfirmationsController < ApplicationController
  before_action :redirect_if_authenticated, only: [:create, :new]

  # create action will resend confirmation instructions to an unconfirmed user
  # if user is not present it will flash alert
  def create
    @user = User.find_by(email: params[:user][:email].downcase)

    if @user.present? && @user.unconfirmed?
      token = @user.send_confirmation_email!
      url = edit_confirmation_url(token)
      redirect_to root_path, flash: { notice: I18n.t('check_your_email'), confirm_url: url }
    else
      redirect_to new_confirmation_path, alert: "We could not find a user with that email or that email has already been confirmed."
    end
  end

  # The edit action is used to confirm a user's email
  # This will be the page that a user lands on when they click the confirmation link in their email.
  # The confirmation_token is randomly generated and can't be guessed or tampered with unlike an email or numeric ID.
  # This is also why we added param: :confirmation_token as a named route parameter
  # The :param option overrides the default resource identifier :id
  def edit
    @user = User.find_signed(params[:confirmation_token], purpose: :confirm_email)
    if @user.present? && @user.unconfirmed_or_reconfirming?
      if @user.confirm!
        login @user
        redirect_to root_path, notice: I18n.t('account_confirmed')
      else
        redirect_to new_confirmation_path, alert: I18n.t('something_went_wrong')
      end
    else
      redirect_to new_confirmation_path, alert: I18n.t('invalid_token')
    end
  end

  def new
    @user = User.new
  end
end
