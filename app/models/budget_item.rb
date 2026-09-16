class BudgetItem < ApplicationRecord
  belongs_to :budget
  belongs_to :rate
  has_many :time_entries, dependent: :restrict_with_error
end
