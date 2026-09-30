require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  setup do
    @budget = budgets(:acme_draft)
  end

  test "rule 1: total is hours x rate plus the buffer" do
    @budget.update!(buffer_percentage: 10)
    @budget.budget_items.create!(description: "API", estimated_hours: 10, level: :senior)

    assert_equal BigDecimal("418000"), @budget.reload.total # 10 h x 38.000 x 1,10
  end

  test "rule 2: a later rate change does not alter an issued budget" do
    item = @budget.budget_items.create!(description: "API", estimated_hours: 10, level: :senior)
    Rate.create!(level: :senior, hourly_value: 50_000, valid_from: Date.current)

    assert_equal rates(:senior_current), item.reload.rate
    assert_equal BigDecimal("380000"), @budget.reload.total
  end

  test "rule 3: only a sent budget can be approved" do
    assert_not @budget.approve
    assert @budget.draft?

    sent = budgets(:acme_sent)
    assert sent.approve
    assert sent.reload.approved?
    assert_not_nil sent.approved_at
  end

  test "rule 3: a decided budget cannot change its decision" do
    sent = budgets(:acme_sent)
    sent.reject

    assert_not sent.approve
    assert sent.reload.rejected?
  end

  test "rule 4: items of a non-draft budget cannot be modified" do
    item = budget_items(:acme_sent_login)

    assert_not item.update(estimated_hours: 1)
    assert_includes item.errors.full_messages.join, "creá una nueva versión"
  end

  test "rule 5: an empty budget cannot be sent" do
    assert_not @budget.send_to_client
    assert @budget.reload.draft?
  end

  test "rule 6: non-billable items are not charged to the client" do
    @budget.budget_items.create!(description: "API", estimated_hours: 10, level: :senior)
    @budget.budget_items.create!(description: "CI interno", estimated_hours: 5, level: :senior, billable: false)

    assert_equal BigDecimal("380000"), @budget.reload.total
  end

  test "only one approved budget per project" do
    budgets(:acme_sent).approve
    @budget.status = :approved

    assert_not @budget.valid?
  end
end
