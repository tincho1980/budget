class MaintenanceCharge < ApplicationRecord
  belongs_to :maintenance_contract
  has_many :payment_applications, dependent: :restrict_with_error
  has_many :payments, through: :payment_applications

  enum :status, { pending: 0, partial: 1, paid: 2, overdue: 3 }, validate: true

  validates :period, format: { with: /\A\d{4}-(0[1-9]|1[0-2])\z/ },
    uniqueness: { scope: :maintenance_contract_id }
  validates :amount, numericality: { greater_than: 0 }
  validates :due_on, presence: true

  scope :unpaid, -> { where.not(status: :paid) }

  # Summed in Ruby so preloaded applications don't trigger one query per charge.
  def paid_amount
    payment_applications.sum(&:applied_amount)
  end

  def balance
    amount - paid_amount
  end

  def days_overdue
    [ (Date.current - due_on).to_i, 0 ].max
  end

  # Rules 12 and 15: status follows from what was applied and the due date.
  def refresh_status!
    applied = payment_applications.sum(:applied_amount)
    new_status =
      if applied >= amount then :paid
      elsif applied.positive? then :partial
      elsif due_on < Date.current then :overdue
      else :pending
      end
    update!(status: new_status)
  end
end
