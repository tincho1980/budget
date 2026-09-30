require "test_helper"

class PaymentTest < ActiveSupport::TestCase
  setup do
    @client = clients(:acme)
  end

  def new_payment(amount, status: :confirmed)
    @client.payments.create!(registered_by: users(:admin), paid_on: Date.current, amount: amount,
      payment_method: :transfer, status: status)
  end

  test "rule 14: a payment covers several charges, oldest first" do
    new_payment(200_000).apply_to_open_charges!

    assert maintenance_charges(:acme_july).reload.paid?
    assert maintenance_charges(:acme_august).reload.paid?
  end

  test "rule 15: a partial payment leaves the charge partial with its balance" do
    new_payment(130_000).apply_to_open_charges!

    august = maintenance_charges(:acme_august).reload
    assert maintenance_charges(:acme_july).reload.paid?
    assert august.partial?
    assert_equal BigDecimal("70000"), august.balance
  end

  test "rule 14: applications cannot exceed the payment amount" do
    payment = new_payment(50_000)
    application = payment.payment_applications.new(maintenance_charge: maintenance_charges(:acme_july), applied_amount: 60_000)

    assert_not application.valid?
  end

  test "rule 16: client debt only counts unpaid balances" do
    assert_equal BigDecimal("200000"), @client.debt

    new_payment(130_000).apply_to_open_charges!
    assert_equal BigDecimal("70000"), @client.debt
  end

  test "rule 17: a payment in review is not applied until confirmed" do
    payment = new_payment(100_000, status: :pending_review)
    assert_equal BigDecimal("200000"), @client.debt

    payment.confirm!
    assert payment.confirmed?
    assert_equal BigDecimal("100000"), @client.debt
  end
end
