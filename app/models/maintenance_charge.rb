class MaintenanceCharge < ApplicationRecord
  belongs_to :maintenance_contract
  has_many :payment_applications, dependent: :restrict_with_error
  has_many :payments, through: :payment_applications

  enum :status, { pending: 0, partial: 1, paid: 2, overdue: 3 }, validate: true

  validates :period, format: { with: /\A\d{4}-(0[1-9]|1[0-2])\z/ },
    uniqueness: { scope: :maintenance_contract_id }
  validates :amount, numericality: { greater_than: 0 }
  validates :due_on, presence: true
end
