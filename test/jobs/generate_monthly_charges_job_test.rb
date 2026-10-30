require "test_helper"

class GenerateMonthlyChargesJobTest < ActiveJob::TestCase
  setup do
    @contract = maintenance_contracts(:acme_contract)
    @october = Date.new(2026, 10, 1)
  end

  test "creates the month's charge for each active contract, only once" do
    assert_difference -> { @contract.maintenance_charges.where(period: "2026-10").count }, 1 do
      2.times { GenerateMonthlyChargesJob.perform_now(@october) }
    end
  end

  test "skips paused contracts" do
    @contract.paused!

    assert_no_difference -> { MaintenanceCharge.count } do
      GenerateMonthlyChargesJob.perform_now(@october)
    end
  end

  test "skips contracts that ended or have not started yet" do
    @contract.update!(ends_on: Date.new(2026, 9, 30))
    assert_no_difference(-> { MaintenanceCharge.count }) { GenerateMonthlyChargesJob.perform_now(@october) }

    @contract.update!(ends_on: nil, starts_on: Date.new(2026, 11, 1))
    assert_no_difference(-> { MaintenanceCharge.count }) { GenerateMonthlyChargesJob.perform_now(@october) }
  end
end
