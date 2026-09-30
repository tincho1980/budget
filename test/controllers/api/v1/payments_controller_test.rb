require "test_helper"
require_relative "api_test_helper"

class Api::V1::PaymentsControllerTest < ActionDispatch::IntegrationTest
  include ApiTestHelper

  setup { @headers = auth_headers(users(:acme_portal)) }

  test "a reported payment stays in review and applies nothing" do
    assert_difference -> { clients(:acme).payments.pending_review.count }, 1 do
      post api_v1_payments_path, headers: @headers, as: :json,
        params: { amount: "100000", paid_on: Date.current, payment_method: "transfer" }
    end

    assert_response :created
    assert_equal "pending_review", json.dig("payment", "status")
    assert_equal 0, PaymentApplication.count
  end

  test "an invalid payment returns the validation errors" do
    post api_v1_payments_path, headers: @headers, as: :json, params: { amount: "-1", payment_method: "bitcoin" }

    assert_response :unprocessable_content
    assert_includes json.dig("error", "details"), "Monto debe ser mayor que 0"
  end

  test "account shows the client's debt" do
    get api_v1_account_path, headers: @headers

    assert_response :success
    assert_equal "200000.00", json.dig("account", "debt")
    assert_equal 2, json.dig("account", "overdue_charges")
  end
end
