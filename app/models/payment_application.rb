class PaymentApplication < ApplicationRecord
  belongs_to :payment
  belongs_to :maintenance_charge

  validates :applied_amount, numericality: { greater_than: 0 }
  validates :maintenance_charge_id, uniqueness: { scope: :payment_id }
  validate :within_payment_amount
  validate :within_charge_balance

  after_save :refresh_charge_status
  after_destroy :refresh_charge_status

  private

  # Rule 14: a payment can't be applied for more than its amount.
  def within_payment_amount
    return if applied_amount.nil? || payment.nil?

    already_applied = payment.payment_applications.where.not(id: id).sum(:applied_amount)
    errors.add(:applied_amount, "supera el monto disponible del pago") if already_applied + applied_amount > payment.amount
  end

  def within_charge_balance
    return if applied_amount.nil? || maintenance_charge.nil?

    already_applied = maintenance_charge.payment_applications.where.not(id: id).sum(:applied_amount)
    errors.add(:applied_amount, "supera el saldo de la cuota") if already_applied + applied_amount > maintenance_charge.amount
  end

  def refresh_charge_status
    maintenance_charge.refresh_status!
  end
end
