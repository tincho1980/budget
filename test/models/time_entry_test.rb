require "test_helper"

class TimeEntryTest < ActiveSupport::TestCase
  test "rejects more than 24 hours" do
    entry = TimeEntry.new(budget_item: budget_items(:acme_sent_login), user: users(:developer), worked_on: Date.current, hours: 25)

    assert_not entry.valid?
  end

  test "rule 8: no hours on a closed project" do
    entry = TimeEntry.new(budget_item: budget_items(:closed_item), user: users(:developer), worked_on: Date.current, hours: 2)

    assert_not entry.valid?
    assert_includes entry.errors.full_messages, "No se pueden cargar horas en un proyecto cerrado."
  end

  test "rule 7: deviation is logged minus estimated hours" do
    item = budget_items(:acme_sent_login)
    item.time_entries.create!(user: users(:developer), worked_on: Date.current, hours: 12)

    assert_equal BigDecimal("2"), item.deviation
  end
end
