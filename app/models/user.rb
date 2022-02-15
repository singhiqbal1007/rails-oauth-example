class User < ApplicationRecord
  CONFIRMATION_TOKEN_EXPIRATION = 10.minutes
  MAILER_FROM_EMAIL = "no-reply@example.com"
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
  validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, presence: true, uniqueness: true
  validates :unconfirmed_email, format: {with: URI::MailTo::EMAIL_REGEXP, allow_blank: true}

  def self.authenticate_by(attributes)
    passwords, identifiers = attributes.to_h.partition do |name, value|
      !has_attribute?(name) && has_attribute?("#{name}_digest")
    end.map(&:to_h)

    raise ArgumentError, "One or more password arguments are required" if passwords.empty?
    raise ArgumentError, "One or more finder arguments are required" if identifiers.empty?
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
      if unconfirmed_email.present?
        return false unless update(email: unconfirmed_email, unconfirmed_email: nil)
      end
      update_columns(confirmed_at: Time.current)
    else
      false
    end
  end

  # check if confirmed_at column is present
  def confirmed?
    confirmed_at.present?
  end

  def confirmable_email
    if unconfirmed_email.present?
      unconfirmed_email
    else
      email
    end
  end

  def generate_confirmation_token
    signed_id expires_in: CONFIRMATION_TOKEN_EXPIRATION, purpose: :confirm_email
  end

  def generate_password_reset_token
    signed_id expires_in: PASSWORD_RESET_TOKEN_EXPIRATION, purpose: :reset_password
  end

  def send_confirmation_email!
    confirmation_token = generate_confirmation_token
    UserMailer.confirmation(self, confirmation_token).deliver_now
  end

  def send_password_reset_email!
    password_reset_token = generate_password_reset_token
    UserMailer.password_reset(self, password_reset_token).deliver_now
  end

  # check if unconfirmed_email column is present
  def reconfirming?
    unconfirmed_email.present?
  end

  # opposite of confirm method
  def unconfirmed?
    !confirmed?
  end

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
