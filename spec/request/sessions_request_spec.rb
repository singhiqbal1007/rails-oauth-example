require 'rails_helper'
RSpec.describe 'Sessions', type: :request do
  include SessionsHelper

  describe 'GET /login' do
    let(:confirmed_user) { create(:user, :confirmed_now) }

    it 'should get login if anonymous' do
      get login_path
      expect(response).to be_successful
    end

    describe 'confirmed user login' do

      before do
        login confirmed_user
      end

      it 'should redirect from login if authenticated' do
        get login_path
        expect(response).to redirect_to(account_path)
      end

      it 'should create active session if confirmed' do
        expect(confirmed_user.active_sessions.count).to eq(1)
        expect(current_session.to_i).to eq(confirmed_user.active_sessions[0].id.to_i)
      end
    end

    it 'should remember user when logging in' do
      confirmed_user = create(:user, :confirmed_now)
      expect(cookies[:remember_token]).to be_nil
      login confirmed_user, remember_user: true

      expect(current_user).to_not be_nil
      expect(cookies[:remember_token]).to_not be_nil
    end

    it 'should forget user when logging out' do
      login confirmed_user, remember_user: true
      logout
      expect(cookies[:remember_token]).to be_empty
      expect(current_user).to be_nil
      expect(response).to redirect_to(root_path)
    end



  end
end
