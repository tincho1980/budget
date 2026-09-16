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
end
