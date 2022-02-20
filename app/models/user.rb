# frozen_string_literal: true

class User < ApplicationRecord
  # confirmation token is a signed_id, and is set to expire in 10 minutes.
  CONFIRMATION_TOKEN_EXPIRATION = 10.minutes

  # send mail from this address
  MAILER_FROM_EMAIL = 'no-reply@example.com'

  # password reset token is a signed_id, and is set to expire in 10 minutes.
  PASSWORD_RESET_TOKEN_EXPIRATION = 10.minutes

  attr_accessor :current_password

  # Adds methods to set and authenticate against a BCrypt password.
  # This mechanism requires you to have a XXX_digest attribute.
  # Where XXX is the attribute name of your desired password.
  # This work with the password_digest column.
  has_secure_password

  # 1 user can have many active sessions
  has_many :active_sessions, dependent: :destroy

  # before_save is only called after validation has passed
  before_save :downcase_email
  before_save :downcase_unconfirmed_email

  # ensure all emails are valid through a format validation.
  # URI::MailTo::EMAIL_REGEXP validate that the email address is properly formatted.
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true, uniqueness: true
  validates :unconfirmed_email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  # This method is present by default in rails 7.1
  # This class method serves to find a user using the non-password attributes (such as email),
  # and then authenticates that record using the password attributes.
  # Regardless of whether a user is found or authentication succeeds,
  # authenticate_by will take the same amount of time.
  # This prevents timing-based enumeration attacks,
  # wherein an attacker can determine if a password record exists even without knowing the password.
  def self.authenticate_by(attributes)
    passwords, identifiers = attributes.to_h.partition do |name, _value|
      !has_attribute?(name) && has_attribute?("#{name}_digest")
    end.map(&:to_h)

    raise ArgumentError, 'One or more password arguments are required' if passwords.empty?
    raise ArgumentError, 'One or more finder arguments are required' if identifiers.empty?

    if (record = find_by(identifiers))
      record if passwords.count { |name, value| record.public_send(:"authenticate_#{name}", value) } == passwords.size
    else
      new(passwords)
      nil
    end
  end

  # The confirm! method will be called when a user confirms their email address.
  def confirm!
    if unconfirmed_or_reconfirming?
      return false if unconfirmed_email.present? && !update(email: unconfirmed_email, unconfirmed_email: nil)

      # rubocop:disable Rails/SkipsModelValidations
      update_columns(confirmed_at: Time.current)
      # rubocop:enable Rails/SkipsModelValidations
    else
      false
    end
  end

  # check if confirmed_at column is present
  def confirmed?
    confirmed_at.present?
  end

  # This method will send unconfirmed_email if user email is not confirmed
  # This will send user email if email is confirmed
  # Therefore, this same method can be used to reset password.
  def confirmable_email
    unconfirmed_email.presence || email
  end

  # signed token to generate confirmation
  def generate_confirmation_token
    # Returns a signed id that's generated using a preconfigured +ActiveSupport::MessageVerifier+ instance.
    # Part of activerecord gem.
    signed_id expires_in: CONFIRMATION_TOKEN_EXPIRATION, purpose: :confirm_email
  end

  # signed token to reset password
  def generate_password_reset_token
    signed_id expires_in: PASSWORD_RESET_TOKEN_EXPIRATION, purpose: :reset_password
  end

  # send confirmation email using UserMailer
  def send_confirmation_email!
    confirmation_token = generate_confirmation_token
    UserMailer.confirmation(self, confirmation_token).deliver_now

    # we will show this token in the flash message for demo
    confirmation_token
  end

  def send_password_reset_email!
    password_reset_token = generate_password_reset_token
    UserMailer.password_reset(self, password_reset_token).deliver_now

    # we will show this token in the flash message for demo
    password_reset_token
  end

  # check if unconfirmed_email column is present
  def reconfirming?
    unconfirmed_email.present?
  end

  # opposite of confirm method
  def unconfirmed?
    !confirmed?
  end

  # We add @user.unconfirmed_or_reconfirming? to the conditional to ensure
  # that only unconfirmed users or users who are reconfirming can have access
  # This is necessary since we're now allowing users to confirm new email addresses.
  def unconfirmed_or_reconfirming?
    unconfirmed? || reconfirming?
  end

  private

  # save all emails to the database in a downcase format via a before_save callback,
  # so that the values are saved in a consistent format.
  def downcase_email
    self.email = email.downcase
  end

  # downcase unconfirmed email
  def downcase_unconfirmed_email
    return if unconfirmed_email.nil?

    self.unconfirmed_email = unconfirmed_email.downcase
  end
end
