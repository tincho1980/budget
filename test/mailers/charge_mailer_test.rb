require "test_helper"

class ChargeMailerTest < ActionMailer::TestCase
  setup do
    @contract = maintenance_contracts(:acme_contract)
  end

  test "due_reminder goes to the contact email and the portal users" do
    charge = @contract.maintenance_charges.create!(period: "2099-01", amount: 100_000, due_on: Date.new(2099, 1, 10))
    mail = ChargeMailer.due_reminder(charge)

    assert_equal [ "contacto@acme.com.ar", "portal@acme.com.ar" ], mail.to
    assert_equal "Recordatorio: tu cuota 2099-01 vence el 10/01/2099", mail.subject
    assert_match "$100.000,00", mail.text_part.body.to_s
  end

  test "overdue_notice shows the balance and the total debt" do
    mail = ChargeMailer.overdue_notice(maintenance_charges(:acme_july))
    body = mail.text_part.body.to_s

    assert_equal "Cuota 2026-07 vencida: saldo pendiente de $100.000,00", mail.subject
    assert_match "días de atraso", body
    assert_match "$200.000,00", body # two unpaid charges in the fixtures
  end

  test "nothing is delivered when the client has no email at all" do
    clients(:acme).update!(email: nil)
    users(:acme_portal).destroy

    assert_emails 0 do
      ChargeMailer.overdue_notice(maintenance_charges(:acme_july)).deliver_now
    end
  end
end
