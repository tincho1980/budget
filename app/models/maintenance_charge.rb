class MaintenanceCharge < ApplicationRecord
  belongs_to :maintenance_contract
  has_many :payment_applications, dependent: :restrict_with_error
  has_many :payments, through: :payment_applications
end
