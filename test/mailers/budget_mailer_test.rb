require "test_helper"

class BudgetMailerTest < ActionMailer::TestCase
  test "sent_to_client goes to the client's portal users with the total" do
    mail = BudgetMailer.sent_to_client(budgets(:acme_sent))

    assert_equal [ "portal@acme.com.ar" ], mail.to
    assert_equal [ "no-responder@adavra.com" ], mail.from
    assert_equal "Presupuesto listo para aprobar: Sitio web Acme", mail.subject
    assert_match "$380.000,00", mail.text_part.body.to_s
    assert_match "Login", mail.html_part.body.to_s
  end

  test "sent_to_client is not delivered when the client has no portal users" do
    users(:globex_portal).destroy

    assert_emails 0 do
      BudgetMailer.sent_to_client(budgets(:globex_sent)).deliver_now
    end
  end

  test "decision_notice tells the admins and links to the budget" do
    budget = budgets(:acme_sent)
    budget.approve
    mail = BudgetMailer.decision_notice(budget)

    assert_equal [ "admin@example.com" ], mail.to
    assert_equal "Acme SA aprobó el presupuesto v1", mail.subject
    assert_match "/admin/budgets/#{budget.id}", mail.html_part.body.to_s
  end
end
