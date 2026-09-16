class Payment < ApplicationRecord
  belongs_to :client
  belongs_to :registered_by, class_name: "User", inverse_of: :registered_payments
  has_many :payment_applications, dependent: :destroy
  has_many :maintenance_charges, through: :payment_applications

  enum :payment_method, { transfer: 0, cash: 1, check: 2 }
  enum :status, { pending_review: 0, confirmed: 1, rejected: 2 }
end
