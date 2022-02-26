# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'OIDC Login', type: :request do
  before do
    config = build(:oidc_configs, :with_authorization_endpoint, :with_token_endpoint, :updated_now)
    allow(OidcConfigs).to receive(:find_by).with({ name: 'google' }).and_return(nil)
    allow(OidcConfigs).to receive(:create).and_return(config)
    stub_const('ENV', { 'GOOGLE_CLIENT_ID' => 'fake_client_id', 'GOOGLE_CLIENT_SECRET' => 'fake_client_secret' })
    @client = OidcLoginHelper::GoogleOidc.client('http://localhost:3000')
  end

  context 'oidc requests' do
    before { allow(OidcLoginHelper::GoogleOidc).to receive(:client).with(root_url).and_return(@client) }

    context 'auth uri' do
      before do
        allow(SecureRandom).to receive(:hex).with(16).and_call_original
        allow(SecureRandom).to receive(:hex).with(10).and_return('abcd1234')
      end

      it 'should redirect to authorization uri' do
        post oidc_login_path
        auth_uri = 'http://fakesite.fake/auth?client_id=fake_client_id&prompt=consent&redirect_uri=http%3A%2F%2Flocalhost%3A3000%2Foauth_callback&response_type=code&scope=openid%20email&state=abcd1234'
        expect(response).to redirect_to(auth_uri)
      end
    end

    context 'callback url with invalid code' do
      before do
        allow(OidcLoginHelper::GoogleOidc).to receive(:request_for_token).with(@client.class).and_return(nil)
      end

      it 'should redirect to root if code is not present in params' do
        get oauth_callback_path
        expect(response).to redirect_to(root_path)
      end

      it 'should redirect to root with alert if code is invalid' do
        get oauth_callback_path, params: { code: 'invalid' }
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq(I18n.t('oauth_login_error'))
      end
    end

    context 'callback url with valid code' do
      context 'user not present' do
        before do
          new_user = build(:user)
          payload = {
            'email' => new_user.email
          }
          encrypted_payload = JSON::JWT.new(payload).encrypt(nil).plain_text
          token = OpenIDConnect::AccessToken.new(client: 'dummy', access_token: 'anything', id_token: encrypted_payload)
          allow(OidcLoginHelper::GoogleOidc).to receive(:request_for_token).with(@client.class).and_return(token)
        end

        it 'should create the user' do
          expect  do
            get oauth_callback_path, params: { code: '123456abc' }
            expect(response).to redirect_to(account_path)
          end.to change(User, :count).by(1)
        end
      end

      context 'with unconfirmed user' do
        before do
          @unconfirmed_user = create(:user)
          payload = {
            'email' => @unconfirmed_user.email
          }
          encrypted_payload = JSON::JWT.new(payload).encrypt(nil).plain_text
          token = OpenIDConnect::AccessToken.new(client: 'dummy', access_token: 'anything', id_token: encrypted_payload)
          allow(OidcLoginHelper::GoogleOidc).to receive(:request_for_token).with(@client.class).and_return(token)
          stubbed_time_current = Time.current
          allow(Time).to receive(:current).and_return(stubbed_time_current)
        end

        it 'should confirm the user' do
          expect do
            get oauth_callback_path, params: { code: '123456abc' }
            expect(response).to redirect_to(account_path)
          end.to change(User, :count).by(0)
          expect(@unconfirmed_user.reload.confirmed_at).to be_within(1.second).of Time.current
        end
      end

      context 'with confirmed user' do
        before do
          @confirmed_user = create(:user, :confirmed_now)
          payload = {
            'email' => @confirmed_user.email
          }
          encrypted_payload = JSON::JWT.new(payload).encrypt(nil).plain_text
          token = OpenIDConnect::AccessToken.new(client: 'dummy', access_token: 'anything', id_token: encrypted_payload)
          allow(OidcLoginHelper::GoogleOidc).to receive(:request_for_token).with(@client.class).and_return(token)
        end

        it 'should confirm the user' do
          expect  do
            get oauth_callback_path, params: { code: '123456abc' }
            expect(response).to redirect_to(account_path)
          end.to change(User, :count).by(0)
        end
      end
    end
  end
end
