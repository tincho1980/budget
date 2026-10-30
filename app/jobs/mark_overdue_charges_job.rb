# Rule 12: a pending charge past its due date becomes overdue, and the client
# gets the notice of arrears once, on the day it changes.
class MarkOverdueChargesJob < ApplicationJob
  queue_as :default

  def perform
    MaintenanceCharge.pending.where(due_on: ...Date.current).find_each do |charge|
      charge.refresh_status!
      ChargeMailer.overdue_notice(charge).deliver_later if charge.overdue?
    end
  end
end
