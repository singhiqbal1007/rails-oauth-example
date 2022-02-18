require 'rails_helper'

RSpec.describe User, :type => :model do
  let(:user) { build(:user) }

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
      user.confirmed_email = "random@email.com"
      expect(user.reconfirming?).to be_truthy
    end

    it 'should respond to unconfirmed_or_reconfirming?' do
      expect(user.unconfirmed_or_reconfirming?)
    end



  end

end
