# frozen_string_literal: true

FactoryBot.define do
  factory :oidc_configs do
    name { 'fake' }
    issuer { 'http://fakesite.fake' }

    trait :with_authorization_endpoint do
      authorization_endpoint { 'http://fakesite.fake/auth' }
    end

    trait :with_token_endpoint do
      token_endpoint { 'http://fakesite.fake/token' }
    end

    trait :updated_now do
      updated_at { Time.current }
    end
  end
end
