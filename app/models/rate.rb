class Rate < ApplicationRecord
  include SeniorityLevel

  has_many :budget_items, dependent: :restrict_with_error

  validates :level, presence: true
  validates :hourly_value, numericality: { greater_than: 0 }
  validates :valid_from, presence: true, uniqueness: { scope: :level }

  # The rate with the most recent valid_from on or before the given date.
  def self.current_for(level, date = Date.current)
    where(level: level).where(valid_from: ..date).order(valid_from: :desc).first
  end
end
