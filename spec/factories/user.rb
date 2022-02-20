# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "random_email#{n}@random.com" }
    password { 'correct_pass' }

    trait :with_password_confirmation do
      password_confirmation { 'correct_pass' }
    end

    trait :confirmed_now do
      confirmed_at { Time.current }
    end

    trait :confirmed_week_ago do
      confirmed_at { 1.week.ago }
    end

    trait :with_uncomfirmed_email do
      unconfirmed_email { 'unconfirmed_email@example.com' }
    end
  end
end
