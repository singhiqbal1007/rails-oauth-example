require 'rails_helper'
RSpec.describe 'ActiveSession', type: :request do
  include SessionsHelper

  let(:confirmed_user) { create(:user, :confirmed_now, :with_password_confirmation) }

  it 'should get edit' do
    password_reset_token = confirmed_user.generate_password_reset_token

    get edit_password_path(password_reset_token)
    expect(response).to be_successful
  end

  describe 'token expired' do

    before(:each) do
      @password_reset_token = confirmed_user.generate_password_reset_token
      stubbed_time = Time.now + 601.seconds
      allow(Time).to receive(:now).and_return(stubbed_time)
    end

    it 'should redirect from edit if password link expired' do
      get edit_password_path(@password_reset_token)

      expect(response).to redirect_to(new_password_path)
      expect(flash[:alert]).not_to be_nil
    end
  end


  it 'should redirect from edit if password link is incorrect' do
    get edit_password_path('not_a_real_token')

    expect(response).to redirect_to(new_password_path)
    expect(flash[:alert]).not_to be_nil
  end

  it 'should redirect from edit if user is not confirmed' do
    confirmed_user.update!(confirmed_at: nil)
    password_reset_token = confirmed_user.generate_password_reset_token

    get edit_password_path(password_reset_token)

    expect(response).to redirect_to(new_confirmation_path)
    expect(flash[:alert]).not_to be_nil
  end

  it 'should redirect from edit if user is authenticated' do
    password_reset_token = confirmed_user.generate_password_reset_token

    login confirmed_user

    get edit_password_path(password_reset_token)
    expect(response).to redirect_to(account_path)
  end

  it 'should get new' do
    get new_password_path
    expect(response).to be_successful
  end

  it 'should redirect from new if user is authenticated' do
    login confirmed_user

    get new_password_path
    expect(response).to redirect_to(account_path)
  end

  it 'should update password' do
    password_reset_token = confirmed_user.generate_password_reset_token

    put password_path(password_reset_token), params: {
      user: {
        password: 'password',
        password_confirmation: 'password'
      }
    }

    expect(response).to redirect_to(login_path)
  end

  it 'should handle errors' do
    password_reset_token = confirmed_user.generate_password_reset_token

    put password_path(password_reset_token), params: {
      user: {
        password: 'password',
        password_confirmation: 'password_that_does_not_match'
      }
    }

    expect(flash[:alert]).not_to be_nil
  end

  it 'should not update password if authenticated' do
    password_reset_token = confirmed_user.generate_password_reset_token

    login confirmed_user

    put password_path(password_reset_token), params: {
      user: {
        password: 'password',
        password_confirmation: 'password'

      }
    }

    get new_password_path
    expect(response).to redirect_to(account_path)
  end
end
