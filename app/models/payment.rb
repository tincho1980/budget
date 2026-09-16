class Payment < ApplicationRecord
  belongs_to :client
  belongs_to :registered_by, class_name: "User", inverse_of: :registered_payments
  has_many :payment_applications, dependent: :destroy
  has_many :maintenance_charges, through: :payment_applications
end
