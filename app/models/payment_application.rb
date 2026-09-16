class PaymentApplication < ApplicationRecord
  belongs_to :payment
  belongs_to :maintenance_charge
end
