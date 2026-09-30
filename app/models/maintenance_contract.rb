class MaintenanceContract < ApplicationRecord
  belongs_to :client
  belongs_to :project, optional: true
  has_many :maintenance_charges, dependent: :restrict_with_error

  enum :status, { active: 0, paused: 1, cancelled: 2 }, validate: true

  validates :monthly_amount, numericality: { greater_than: 0 }
  # Capped at 28 so every month, February included, has that day.
  validates :due_day, numericality: { only_integer: true, in: 1..28 }
  validates :starts_on, presence: true
  validates :ends_on, comparison: { greater_than_or_equal_to: :starts_on }, allow_nil: true

  # Rules 10, 11 and 13: copies the current amount, never duplicates a period,
  # and only active contracts generate new charges.
  def generate_charge_for(date = Date.current)
    return unless active?

    month = date.beginning_of_month
    period = month.strftime("%Y-%m")
    maintenance_charges.create_with(amount: monthly_amount, due_on: month.change(day: due_day))
      .find_or_create_by!(period: period)
  rescue ActiveRecord::RecordNotUnique
    maintenance_charges.find_by!(period: period)
  end
end
