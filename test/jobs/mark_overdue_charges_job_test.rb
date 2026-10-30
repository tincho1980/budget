require "test_helper"

class MarkOverdueChargesJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    @charge = maintenance_contracts(:acme_contract).maintenance_charges.create!(
      period: "2026-10", amount: 100_000, due_on: Date.new(2026, 10, 10)
    )
  end

  test "a pending charge past its due date becomes overdue and the client is notified" do
    travel_to Date.new(2026, 10, 11) do
      assert_enqueued_email_with ChargeMailer, :overdue_notice, args: [ @charge ] do
        MarkOverdueChargesJob.perform_now
      end
    end

    assert @charge.reload.overdue?
  end

  test "a charge on its due date is still pending" do
    travel_to Date.new(2026, 10, 10) do
      assert_no_enqueued_emails { MarkOverdueChargesJob.perform_now }
    end

    assert @charge.reload.pending?
  end

  test "a charge that was already overdue is not notified again" do
    travel_to(Date.new(2026, 10, 11)) { MarkOverdueChargesJob.perform_now }

    travel_to Date.new(2026, 10, 12) do
      assert_no_enqueued_emails { MarkOverdueChargesJob.perform_now }
    end
  end
end
