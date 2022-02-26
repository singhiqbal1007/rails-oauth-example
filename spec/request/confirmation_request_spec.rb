# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'ActiveSession', type: :request do
  include SessionsHelper

  let(:unconfirmed_user) { create(:user) }
  let(:confirmed_user) { create(:user, :confirmed_now, :with_password_confirmation) }
  let(:reconfirmed_user) { create(:user, :with_password_confirmation, :confirmed_week_ago, :with_uncomfirmed_email) }

  describe 'token not expired' do
    before(:each) do
      stubbed_time_current = Time.current
      allow(Time).to receive(:current).and_return(stubbed_time_current)
    end

    it 'should confirm unconfirmed user' do
      confirmation_token = unconfirmed_user.generate_confirmation_token

      get edit_confirmation_path(confirmation_token)

      expect(unconfirmed_user.reload.confirmed?).to eq(true)
      expect(unconfirmed_user.reload.confirmed_at).to be_within(1.second).of Time.current
      expect(response).to redirect_to(root_path)
    end

    it 'should not update email address if already taken' do
      original_email = reconfirmed_user.email
      reconfirmed_user.update(unconfirmed_email: confirmed_user.email)
      confirmation_token = reconfirmed_user.generate_confirmation_token

      get edit_confirmation_path(confirmation_token)

      expect(original_email).to eq(reconfirmed_user.reload.email)
      expect(response).to redirect_to(new_confirmation_path)
    end
  end

  describe 'token expired' do
    before(:each) do
      @confirmation_token = unconfirmed_user.generate_confirmation_token
      stubbed_time = 601.seconds.from_now
      allow(Time).to receive(:now).and_return(stubbed_time)
    end

    it 'should redirect if confirmation link expired' do
      get edit_confirmation_path(@confirmation_token)
      expect(unconfirmed_user.reload.confirmed_at).to be_nil
      expect(unconfirmed_user.reload.confirmed?).to be_falsey

      expect(response).to redirect_to(new_confirmation_path)
    end
  end

  it 'should redirect if confirmation link is incorrect' do
    get edit_confirmation_path('not_a_real_token')
    expect(response).to redirect_to(new_confirmation_path)
  end

  it 'should prevent user from confirming if they are already confirmed' do
    post confirmations_path, params: { user: { email: confirmed_user.email } }
    expect(response).to redirect_to(new_confirmation_path)
  end

  it 'should get new if not authenticated' do
    get new_confirmation_path
    expect(response).to be_successful
  end

  it 'should prevent authenticated user from confirming' do
    confirmation_token = confirmed_user.generate_confirmation_token
    login confirmed_user
    get edit_confirmation_path(confirmation_token)
    expect(response).to redirect_to(new_confirmation_path)
  end

  it 'should prevent authenticated user from submitting the confirmation form' do
    login confirmed_user

    get new_confirmation_path
    expect(response).to redirect_to(account_path)

    post confirmations_path, params: { user: { email: confirmed_user.email } }

    expect(response).to redirect_to(account_path)
  end
end
