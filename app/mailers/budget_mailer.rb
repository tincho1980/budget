class BudgetMailer < ApplicationMailer
  # To the client's portal users: a budget is ready to approve or reject.
  def sent_to_client(budget)
    @budget = budget
    @client = budget.project.client
    @modules = budget.budget_items.select(&:billable).group_by { |item| item.module_name.presence || "General" }
    recipients = @client.users.pluck(:email_address)
    return if recipients.empty?

    mail to: recipients, subject: "Presupuesto listo para aprobar: #{budget.project.name}"
  end

  # To the admins: the client approved or rejected a budget from the portal.
  def decision_notice(budget)
    @budget = budget
    @client = budget.project.client
    @decision = budget.approved? ? "aprobó" : "rechazó"
    recipients = User.role_admin.pluck(:email_address)
    return if recipients.empty?

    mail to: recipients, subject: "#{@client.business_name} #{@decision} el presupuesto v#{budget.version}"
  end
end
