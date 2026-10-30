require "test_helper"

class SendDueRemindersJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  setup do
    @charge = maintenance_contracts(:acme_contract).maintenance_charges.create!(
      period: "2026-10", amount: 100_000, due_on: Date.new(2026, 10, 10)
    )
  end

  test "reminds the client three days before the due date" do
    travel_to Date.new(2026, 10, 7) do
      assert_enqueued_email_with ChargeMailer, :due_reminder, args: [ @charge ] do
        SendDueRemindersJob.perform_now
      end
    end
  end

  test "sends nothing on other days" do
    [ Date.new(2026, 10, 6), Date.new(2026, 10, 8) ].each do |day|
      travel_to(day) { assert_no_enqueued_emails { SendDueRemindersJob.perform_now } }
    end
  end

  test "a charge that is already paid gets no reminder" do
    @charge.update!(status: :paid)

    travel_to Date.new(2026, 10, 7) do
      assert_no_enqueued_emails { SendDueRemindersJob.perform_now }
    end
  end
end
