class Client < ApplicationRecord
  has_many :projects, dependent: :restrict_with_error
  has_many :maintenance_contracts, dependent: :restrict_with_error
  has_many :maintenance_charges, through: :maintenance_contracts
  has_many :payments, dependent: :restrict_with_error
  has_many :users, dependent: :restrict_with_error
end
