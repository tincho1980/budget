class BudgetItem < ApplicationRecord
  include SeniorityLevel

  belongs_to :budget
  belongs_to :rate
  has_many :time_entries, dependent: :restrict_with_error

  validates :description, presence: true
  validates :level, presence: true
  validates :estimated_hours, numericality: { greater_than: 0 }
end
