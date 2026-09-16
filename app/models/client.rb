class Client < ApplicationRecord
  has_many :projects, dependent: :restrict_with_error
  has_many :maintenance_contracts, dependent: :restrict_with_error
  has_many :maintenance_charges, through: :maintenance_contracts
  has_many :payments, dependent: :restrict_with_error
  has_many :users, dependent: :restrict_with_error

  validates :business_name, presence: true
  validates :tax_id, uniqueness: true, allow_blank: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
