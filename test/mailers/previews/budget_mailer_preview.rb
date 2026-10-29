# Preview at http://localhost:3000/rails/mailers/budget_mailer
class BudgetMailerPreview < ActionMailer::Preview
  def sent_to_client
    BudgetMailer.sent_to_client(Budget.sent.first || Budget.first)
  end

  def decision_notice
    BudgetMailer.decision_notice(Budget.approved.first || Budget.first)
  end
end
