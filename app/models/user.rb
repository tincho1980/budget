class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  belongs_to :client, optional: true
  has_many :time_entries, dependent: :restrict_with_error
  has_many :registered_payments, class_name: "Payment", foreign_key: :registered_by_id,
    inverse_of: :registered_by, dependent: :restrict_with_error

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
