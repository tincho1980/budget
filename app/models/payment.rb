class Payment < ApplicationRecord
  belongs_to :client
  belongs_to :registered_by, class_name: "User", inverse_of: :registered_payments
  has_many :payment_applications, dependent: :destroy
  has_many :maintenance_charges, through: :payment_applications

  enum :payment_method, { transfer: 0, cash: 1, check: 2 }, validate: true
  enum :status, { pending_review: 0, confirmed: 1, rejected: 2 }, validate: true

  validates :paid_on, presence: true
  validates :amount, numericality: { greater_than: 0 }

  def applied_amount
    payment_applications.sum(:applied_amount)
  end

  def unapplied_amount
    amount - applied_amount
  end

  # Rule 17: a payment reported from the portal only counts once confirmed.
  def confirm!
    transaction do
      update!(status: :confirmed)
      apply_to_open_charges!
    end
  end

  def reject!
    update!(status: :rejected)
  end

  # Rule 14: applies the amount to the oldest unpaid charges first.
  def apply_to_open_charges!
    remaining = unapplied_amount

    client.maintenance_charges.unpaid.reorder(:due_on).each do |charge|
      break unless remaining.positive?

      applied = [ remaining, charge.balance ].min
      next unless applied.positive?

      payment_applications.create!(maintenance_charge: charge, applied_amount: applied)
      remaining -= applied
    end
  end
end
