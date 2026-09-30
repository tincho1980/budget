json.extract! charge, :id, :period, :due_on, :status
json.amount format("%.2f", charge.amount)
json.paid_amount format("%.2f", charge.paid_amount)
json.balance format("%.2f", charge.balance)
json.days_overdue charge.overdue? ? charge.days_overdue : 0
