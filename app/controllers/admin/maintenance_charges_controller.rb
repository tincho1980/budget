class Admin::MaintenanceChargesController < Admin::BaseController
  def index
    @charges = MaintenanceCharge.includes(:payment_applications, maintenance_contract: :client)
      .order(due_on: :desc)
    @charges = @charges.where(status: params[:status]) if MaintenanceCharge.statuses.key?(params[:status])
  end

  # Before the due date it is a reminder; after it, a notice of arrears.
  def send_reminder
    charge = MaintenanceCharge.find(params[:id])
    client = charge.maintenance_contract.client

    if charge.paid?
      alert = "La cuota #{charge.period} ya está pagada."
    elsif client.notification_emails.empty?
      alert = "#{client.business_name} no tiene email de contacto ni usuarios del portal."
    else
      mail = charge.due_on < Date.current ? ChargeMailer.overdue_notice(charge) : ChargeMailer.due_reminder(charge)
      mail.deliver_later
      notice = "Aviso de la cuota #{charge.period} enviado a #{client.notification_emails.to_sentence}."
    end

    redirect_back_or_to admin_maintenance_charges_path, notice: notice, alert: alert
  end
end
