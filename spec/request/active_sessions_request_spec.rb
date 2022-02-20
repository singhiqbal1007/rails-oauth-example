# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'ActiveSession', type: :request do
  include SessionsHelper

  let(:confirmed_user) { create(:user, :confirmed_now) }

  it 'should destroy all active sessions' do
    login confirmed_user
    confirmed_user.active_sessions.create!

    expect { delete destroy_all_active_sessions_path }.to change { ActiveSession.count }.by(-2)
    expect(response).to redirect_to(root_path)
    expect(current_user).to be_nil
  end

  it 'should destroy all active sessions and forget active sessions' do
    login confirmed_user, remember_user: true
    confirmed_user.active_sessions.create!

    expect { delete destroy_all_active_sessions_path }.to change { ActiveSession.count }.by(-2)

    expect(current_user).to be_nil
    expect(cookies[:remember_token]).to be_empty
  end

  it 'should destroy another session' do
    login confirmed_user
    confirmed_user.active_sessions.create!

    expect { delete active_session_path(confirmed_user.active_sessions.last) }.to change { ActiveSession.count }.by(-1)

    expect(response).to redirect_to(account_path)
    expect(current_user).not_to be_nil
  end

  it 'should destroy current session' do
    login confirmed_user

    expect { delete active_session_path(confirmed_user.active_sessions.last) }.to change { ActiveSession.count }.by(-1)

    expect(response).to redirect_to(root_path)
    expect(current_user).to be_nil
  end

  it 'should destroy current session and forget current active session' do
    login confirmed_user, remember_user: true

    expect { delete active_session_path(confirmed_user.active_sessions.last) }.to change { ActiveSession.count }.by(-1)

    expect(current_user).to be_nil
    expect(cookies[:remember_token]).to be_empty
  end
end
