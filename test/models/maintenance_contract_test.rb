require "test_helper"

class MaintenanceContractTest < ActiveSupport::TestCase
  setup do
    @contract = maintenance_contracts(:acme_contract)
    @month = Date.new(2026, 10, 1)
  end

  test "rule 11: generating the same period twice does not duplicate it" do
    assert_difference -> { @contract.maintenance_charges.count }, 1 do
      2.times { @contract.generate_charge_for(@month) }
    end
  end

  test "rule 11: the database also rejects a duplicated period" do
    assert_raises ActiveRecord::RecordNotUnique do
      MaintenanceCharge.insert_all!([ { maintenance_contract_id: @contract.id, period: maintenance_charges(:acme_july).period, amount: 1, due_on: Date.current } ])
    end
  end

  test "rule 10: the charge keeps the amount it was generated with" do
    charge = @contract.generate_charge_for(@month)
    @contract.update!(monthly_amount: 150_000)

    assert_equal BigDecimal("100000"), charge.reload.amount
    assert_equal Date.new(2026, 10, 10), charge.due_on
  end

  test "rule 13: a paused contract stops generating charges but keeps its debt" do
    @contract.paused!

    assert_nil @contract.generate_charge_for(@month)
    assert_equal 2, @contract.maintenance_charges.overdue.count
  end

  test "due day is capped at 28" do
    @contract.due_day = 31

    assert_not @contract.valid?
  end
end
