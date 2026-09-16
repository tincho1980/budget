class PaymentApplication < ApplicationRecord
  belongs_to :payment
  belongs_to :maintenance_charge

  validates :applied_amount, numericality: { greater_than: 0 }
  validates :maintenance_charge_id, uniqueness: { scope: :payment_id }
end
