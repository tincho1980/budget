json.extract! payment, :id, :paid_on, :payment_method, :status, :notes, :created_at
json.amount format("%.2f", payment.amount)
