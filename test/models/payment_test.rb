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

  test "accepts a PDF or image receipt" do
    payment = new_payment(100_000, status: :pending_review)

    payment.receipt = { io: File.open(file_fixture("comprobante.pdf")), filename: "comprobante.pdf" }
    assert payment.valid?
    payment.receipt = { io: File.open(file_fixture("comprobante.png")), filename: "comprobante.png" }
    assert payment.valid?
  end

  test "rejects a receipt that is not a PDF or an image" do
    payment = new_payment(100_000, status: :pending_review)
    payment.receipt = { io: File.open(file_fixture("notas.txt")), filename: "notas.txt" }

    assert_not payment.valid?
    assert_includes payment.errors.full_messages, "Comprobante debe ser PDF, JPG o PNG"
  end

  test "the type is detected from the file's signature, not from what the client declares" do
    payment = new_payment(100_000, status: :pending_review)
    payment.receipt = { io: File.open(file_fixture("comprobante.png")), filename: "foto.txt", content_type: "text/plain" }

    assert payment.valid?
    assert_equal "image/png", payment.receipt.content_type
  end

  test "rejects a receipt larger than 5 MB" do
    payment = new_payment(100_000, status: :pending_review)
    payment.receipt = { io: StringIO.new("%PDF-1.4\n" + ("0" * 6.megabytes)), filename: "grande.pdf" }

    assert_not payment.valid?
    assert_includes payment.errors.full_messages.join, "no puede pesar más de 5 MB"
  end
end
