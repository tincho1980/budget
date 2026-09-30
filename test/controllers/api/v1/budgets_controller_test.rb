require "test_helper"
require_relative "api_test_helper"

class Api::V1::BudgetsControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelper

  setup do
    @budget = budgets(:acme_sent)
    @headers = auth_headers(users(:acme_portal))
  end

  test "shows the budget without internal rates or costs" do
    get api_v1_budget_path(@budget), headers: @headers

    assert_response :success
    assert_equal "380000.00", json.dig("budget", "total")
    assert_no_match(/hourly_value|rate|38000\.0/, response.body.sub('"total":"380000.00"', ""))
  end

  test "approves a sent budget" do
    post approve_api_v1_budget_path(@budget), headers: @headers

    assert_response :success
    assert_equal "approved", json.dig("budget", "status")
    assert @budget.reload.approved?
  end

  test "rejects a sent budget" do
    post reject_api_v1_budget_path(@budget), headers: @headers

    assert_response :success
    assert @budget.reload.rejected?
  end

  test "cannot approve twice" do
    @budget.approve
    post approve_api_v1_budget_path(@budget), headers: @headers

    assert_response :unprocessable_content
  end
end
