class PasswordsController < ApplicationController
  before_action :redirect_if_authenticated

  def create
    @user = User.find_by(email: params[:user][:email].downcase)
    if @user.present?
      if @user.confirmed?
        token = @user.send_password_reset_email!
        url = edit_password_url(token)
        redirect_to root_path, flash: { notice: I18n.t('check_your_email'), reset_url: url }
      else
        redirect_to new_confirmation_path, alert: I18n.t('unconfirmed_email')
      end
    else
      redirect_back fallback_location: root_path, alert: I18n.t('email_does_not_exists')
    end
  end

  def edit
    @user = User.find_signed(params[:password_reset_token], purpose: :reset_password)
    if @user.present? && @user.unconfirmed?
      redirect_to new_confirmation_path, alert: I18n.t('unconfirmed_email')
    elsif @user.nil?
      redirect_to new_password_path, alert: I18n.t('invalid_token')
    end
  end

  def new
  end

  def update
    @user = User.find_signed(params[:password_reset_token], purpose: :reset_password)
    if @user
      if @user.unconfirmed?
        redirect_to new_confirmation_path, alert: I18n.t('unconfirmed_email')
      elsif @user.update(password_params)
        redirect_to login_path, notice: I18n.t('password_changed')
      else
        flash.now[:alert] = @user.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = I18n.t('invalid_token')
      render :new, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
