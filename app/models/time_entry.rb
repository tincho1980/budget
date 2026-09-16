class TimeEntry < ApplicationRecord
  belongs_to :budget_item
  belongs_to :user
end
