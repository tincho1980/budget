class Rate < ApplicationRecord
  include SeniorityLevel

  has_many :budget_items, dependent: :restrict_with_error
end
