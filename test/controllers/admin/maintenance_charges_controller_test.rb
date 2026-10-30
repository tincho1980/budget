require "test_helper"

class Admin::MaintenanceChargesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:developer)) }

  test "an overdue charge gets the notice of arrears" do
    charge = maintenance_charges(:acme_july)

    assert_enqueued_email_with ChargeMailer, :overdue_notice, args: [ charge ] do
      post send_reminder_admin_maintenance_charge_path(charge)
    end
    assert_redirected_to admin_maintenance_charges_path
    assert_match "contacto@acme.com.ar", flash[:notice]
  end

  test "a charge not yet due gets the reminder" do
    charge = maintenance_contracts(:acme_contract).maintenance_charges.create!(period: "2099-01", amount: 100_000, due_on: Date.new(2099, 1, 10))

    assert_enqueued_email_with ChargeMailer, :due_reminder, args: [ charge ] do
      post send_reminder_admin_maintenance_charge_path(charge)
    end
  end

  test "a paid charge sends nothing" do
    charge = maintenance_charges(:acme_july)
    charge.update!(status: :paid)

    assert_no_enqueued_emails do
      post send_reminder_admin_maintenance_charge_path(charge)
    end
    assert_match "ya está pagada", flash[:alert]
  end

  test "a client without any email sends nothing and says why" do
    clients(:acme).update!(email: nil)
    users(:acme_portal).destroy

    assert_no_enqueued_emails do
      post send_reminder_admin_maintenance_charge_path(maintenance_charges(:acme_july))
    end
    assert_match "no tiene email", flash[:alert]
  end

  test "the list shows the button only for unpaid charges" do
    get admin_maintenance_charges_path

    assert_select "button", text: "Avisar mora", count: 2
  end
end
