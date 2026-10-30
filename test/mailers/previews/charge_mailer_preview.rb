# Preview at http://localhost:3000/rails/mailers/charge_mailer
class ChargeMailerPreview < ActionMailer::Preview
  def due_reminder
    charge = MaintenanceCharge.where(due_on: Date.current..).first || MaintenanceCharge.first
    ChargeMailer.due_reminder(charge)
  end

  def overdue_notice
    ChargeMailer.overdue_notice(MaintenanceCharge.overdue.first || MaintenanceCharge.first)
  end
end
