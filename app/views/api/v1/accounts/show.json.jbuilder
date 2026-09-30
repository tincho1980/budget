json.account do
  json.client do
    json.extract! @client, :id, :business_name, :tax_id
  end
  json.debt format("%.2f", @unpaid_charges.sum(BigDecimal("0"), &:balance))
  json.overdue_charges @unpaid_charges.count(&:overdue?)
  json.unpaid_charges @unpaid_charges, partial: "api/v1/charges/charge", as: :charge
  json.recent_payments @recent_payments, partial: "api/v1/payments/payment", as: :payment
end
