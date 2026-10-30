# Creates this month's charge for every active contract. It runs every day, not
# only on the 1st: generate_charge_for never duplicates a period (rule 11), so a
# day the server was down is covered by the next run.
class GenerateMonthlyChargesJob < ApplicationJob
  queue_as :default

  def perform(date = Date.current)
    MaintenanceContract.active.find_each { |contract| contract.generate_charge_for(date) }
  end
end
