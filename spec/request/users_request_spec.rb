# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Users', type: :request do
  include SessionsHelper

  let(:confirmed_user) { create(:user, :confirmed_now) }
  let(:unconfirmed_user) { create(:user) }

  it 'should load sign up page for anonymous users' do
    get sign_up_path
    expect(response).to be_successful
  end

  it 'should redirect authenticated users from signing up' do
    login confirmed_user

    get sign_up_path
    expect(response).to redirect_to(account_path)

    expect do
      post sign_up_path, params: {
        user: {
          email: 'some_unique_email@example.com',
          password: 'password',
          password_confirmation: 'password'
        }
      }
    end.not_to(change { confirmed_user.active_sessions.count })
  end

  it 'should handle errors when signing up' do
    expect do
      post sign_up_path, params: {
        user: {
          email: 'some_unique_email@example.com',
          password: 'password',
          password_confirmation: 'wrong_password'
        }
      }
    end.not_to(change { confirmed_user.active_sessions.count })
  end

  it 'should access account if authorized' do
    login confirmed_user

    get account_path
    expect(response).to be_successful
  end

  it 'should redirect unauthorized user from editing account' do
    get account_path
    expect(response).to redirect_to(login_path)
    expect(flash[:notice]).to be_nil
  end

  it 'should delete user' do
    login confirmed_user

    delete account_path(confirmed_user)

    expect(current_user).to be_nil
    expect(response).to redirect_to(root_path)
    expect(flash[:notice]).to eq('Your account has been deleted.')
  end
end
