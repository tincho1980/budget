require "test_helper"

class Admin::PaymentsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:admin)) }

  test "a payment registered with its receipt shows it" do
    post admin_payments_path, params: { payment: {
      client_id: clients(:acme).id, paid_on: Date.current, amount: 100_000, payment_method: "transfer",
      receipt: fixture_file_upload("comprobante.pdf")
    } }
    payment = Payment.last

    assert payment.receipt.attached?
    follow_redirect!
    assert_select "a", text: "comprobante.pdf"
  end
end
