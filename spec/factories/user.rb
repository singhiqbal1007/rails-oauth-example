FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "random_email#{n}@random.com" }
    password { "random_pass" }
  end
end
