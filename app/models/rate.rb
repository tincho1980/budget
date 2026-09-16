class Rate < ApplicationRecord
  include SeniorityLevel

  has_many :budget_items, dependent: :restrict_with_error

  validates :level, presence: true
  validates :hourly_value, numericality: { greater_than: 0 }
  validates :valid_from, presence: true, uniqueness: { scope: :level }
end
