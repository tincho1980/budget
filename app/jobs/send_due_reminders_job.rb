# Reminds clients a few days before a charge is due. It runs once a day and
# matches a single due date, so each charge gets one reminder.
class SendDueRemindersJob < ApplicationJob
  queue_as :default

  DAYS_BEFORE = 3

  def perform
    MaintenanceCharge.where(status: %i[ pending partial ], due_on: Date.current + DAYS_BEFORE).find_each do |charge|
      ChargeMailer.due_reminder(charge).deliver_later
    end
  end
end
