require "test_helper"

class Admin::BudgetsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:admin)) }

  test "sending a budget emails the client" do
    budget = budgets(:acme_draft)
    budget.budget_items.create!(description: "API", estimated_hours: 10, level: :senior)

    assert_enqueued_email_with BudgetMailer, :sent_to_client, args: [ budget ] do
      post send_to_client_admin_budget_path(budget)
    end
    assert budget.reload.sent?
  end

  test "an empty budget is not sent and emails nobody" do
    assert_no_enqueued_emails do
      post send_to_client_admin_budget_path(budgets(:acme_draft))
    end
  end

  test "the signed PDF can be attached to an approved budget" do
    budget = budgets(:closed_approved)
    patch attach_signed_document_admin_budget_path(budget),
      params: { budget: { signed_document: fixture_file_upload("presupuesto_firmado.pdf") } }

    assert budget.reload.signed_document.attached?
    assert_equal "PDF firmado adjuntado.", flash[:notice]
  end

  test "a budget that is not approved cannot get a signed PDF" do
    budget = budgets(:acme_sent)
    patch attach_signed_document_admin_budget_path(budget),
      params: { budget: { signed_document: fixture_file_upload("presupuesto_firmado.pdf") } }

    assert_not budget.reload.signed_document.attached?
    assert_match "aprobado", flash[:alert]
  end
end
