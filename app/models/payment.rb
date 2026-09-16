class Payment < ApplicationRecord
  belongs_to :client
  belongs_to :registered_by, class_name: "User", inverse_of: :registered_payments
  has_many :payment_applications, dependent: :destroy
  has_many :maintenance_charges, through: :payment_applications

  enum :payment_method, { transfer: 0, cash: 1, check: 2 }, validate: true
  enum :status, { pending_review: 0, confirmed: 1, rejected: 2 }, validate: true

  validates :paid_on, presence: true
  validates :amount, numericality: { greater_than: 0 }
end
