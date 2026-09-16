class User < ApplicationRecord
  include SeniorityLevel

  has_secure_password
  has_secure_token :api_token
  has_many :sessions, dependent: :destroy

  belongs_to :client, optional: true
  has_many :time_entries, dependent: :restrict_with_error
  has_many :registered_payments, class_name: "Payment", foreign_key: :registered_by_id,
    inverse_of: :registered_by, dependent: :restrict_with_error

  # Access levels leave gaps so intermediate roles can be added later.
  enum :role, { client: 50, developer: 80, admin: 100 }, prefix: true, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true
  validate :client_matches_role

  private

  def client_matches_role
    if role_client? && client.nil?
      errors.add(:client, "es obligatorio para usuarios del portal")
    elsif !role_client? && client.present?
      errors.add(:client, "sólo corresponde a usuarios del portal")
    end
  end
end
