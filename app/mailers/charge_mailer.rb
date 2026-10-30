class ChargeMailer < ApplicationMailer
  # Before the due date: the charge is still pending or partially paid.
  def due_reminder(charge)
    prepare(charge)
    return if @recipients.empty?

    mail to: @recipients, subject: "Recordatorio: tu cuota #{charge.period} vence el #{I18n.l(charge.due_on)}"
  end

  # After the due date: the charge still has a balance.
  def overdue_notice(charge)
    prepare(charge)
    return if @recipients.empty?

    mail to: @recipients, subject: "Cuota #{charge.period} vencida: saldo pendiente de #{ActiveSupport::NumberHelper.number_to_currency(charge.balance)}"
  end

  private

  def prepare(charge)
    @charge = charge
    @client = charge.maintenance_contract.client
    @debt = @client.debt
    @recipients = @client.notification_emails
  end
end
