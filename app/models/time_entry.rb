class TimeEntry < ApplicationRecord
  belongs_to :budget_item
  belongs_to :user

  validates :worked_on, presence: true
  validates :hours, numericality: { greater_than: 0, less_than_or_equal_to: 24 }
end
