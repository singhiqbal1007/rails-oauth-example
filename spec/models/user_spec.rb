require 'rails_helper'

RSpec.describe User, :type => :model do
  let(:user) { build(:user) }
  let(:confirmed_user) { build(:user, :confirmed_now, :with_password_confirmation) }
  let(:reconfirmed_user) { build(:user, :with_password_confirmation, :confirmed_week_ago, :with_uncomfirmed_email) }

  context 'validations' do

    it 'should be valid' do
      expect(user).to be_valid
    end

    it 'should have email' do
      user.email = nil
      expect(user).not_to be_valid
    end

    it 'email should be unique' do
      email = user.email
      user.save!
      invalid_user = build(:user, email: email)
      expect(invalid_user).not_to be_valid
    end

    it 'email should be saved as lowercase' do
      email = "UPPERCASE_EMAIL@UPPERCASE.COM"
      valid_user = create(:user, email: email)
      expect(valid_user.email).to eq(email.downcase)
    end

    it 'email should be valid' do
      invalid_emails = %w[foo foo@ foo@bar.]

      invalid_emails.each do |invalid_email|
        user.email = invalid_email
        expect(user).not_to be_valid
      end
    end

    it 'cannot create user without password' do
      user.password = nil
      expect(user).not_to be_valid
    end

    it 'should respond to confirmed?' do
      expect(user.confirmed?).to be_falsey
      user.confirmed_at = Time.now
      expect(user.confirmed?).to be_truthy
    end

    it 'should respond to unconfirmed?' do
      expect(user.unconfirmed?).to be_truthy
      user.confirmed_at = Time.now
      expect(user.unconfirmed?).to be_falsey
    end

    it 'should respond to reconfirming?' do
      expect(user.reconfirming?).to be_falsey
      user.unconfirmed_email = 'random@email.com'
      expect(user.reconfirming?).to be_truthy
    end

    it 'should respond to unconfirmed_or_reconfirming?' do
      expect(user.unconfirmed_or_reconfirming?).to be_truthy
      user.unconfirmed_email = 'random@email.com'
      user.confirmed_at = Time.now
      expect(user.unconfirmed_or_reconfirming?).to be_truthy
    end

    it 'should downcase unconfirmed_email' do
      email = 'UNCONFIRMED_EMAIL@EXAMPLE.COM'
      user.unconfirmed_email = email
      user.save!
      expect(user).to be_valid
    end

    it 'unconfirmed_email should be valid' do
      invalid_emails = %w[foo foo@ foo@bar.]

      invalid_emails.each do |invalid_email|
        user.unconfirmed_email = invalid_email
        expect(user).not_to be_valid
      end
    end

    it 'unconfirmed_email does not need to be available' do
      user.save!
      user.unconfirmed_email = user.email
      assert user.valid?
      expect(user).to be_valid
    end

    it '.confirm! should return false if already confirmed' do
      expect(confirmed_user.confirm!).to be_falsey
    end

    context 'hi' do
      before do
        stubbed_time = Time.current
        allow(Time).to receive(:current).and_return(stubbed_time)
      end

      it '.confirm! should update email if reconfirming' do
        new_email = reconfirmed_user.unconfirmed_email

        reconfirmed_user.confirm!
        expect(new_email).to eq(reconfirmed_user.reload.email)
        expect(reconfirmed_user.unconfirmed_email).to be_nil
        expect(reconfirmed_user.confirmed_at).to be_within(1.second).of Time.current
      end

      it '.confirm! should set confirmed_at' do
        unconfirmed_user = create(:user, :with_password_confirmation)
        unconfirmed_user.confirm!
        expect(unconfirmed_user.confirmed_at).to be_within(1.second).of Time.current
      end
    end

    it '.confirm! should not update email if already taken' do
      confirmed_user = User.create!(email: "user1@example.com", password: "password", password_confirmation: "password")
      reconfirmed_user = User.create!(email: "user2@example.com", password: "password", password_confirmation: "password", confirmed_at: 1.week.ago, unconfirmed_email: confirmed_user.email)
      expect(reconfirmed_user.confirm!).to be_falsey
    end

    it 'should create active session' do
      user.save!
      count = user.active_sessions.count
      user.active_sessions.create!
      expect(user.active_sessions.count).to eq(count + 1)
    end

    it "should destroy associated active session when destryoed" do
      user.save!
      user.active_sessions.create!
      user.destroy!
      expect(user.active_sessions.count).to eq(0)
    end
  end
end
