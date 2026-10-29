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
end
