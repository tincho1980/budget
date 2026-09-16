class MaintenanceCharge < ApplicationRecord
  belongs_to :maintenance_contract
  has_many :payment_applications, dependent: :restrict_with_error
  has_many :payments, through: :payment_applications

  enum :status, { pending: 0, partial: 1, paid: 2, overdue: 3 }
end
