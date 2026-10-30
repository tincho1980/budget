json.extract! payment, :id, :paid_on, :payment_method, :status, :notes, :created_at
json.amount format("%.2f", payment.amount)
if payment.receipt.attached?
  json.receipt do
    json.filename payment.receipt.filename.to_s
    json.content_type payment.receipt.content_type
    json.byte_size payment.receipt.byte_size
    json.url rails_blob_url(payment.receipt)
  end
else
  json.receipt nil
end
