class Budget < ApplicationRecord
  belongs_to :project
  has_many :budget_items, dependent: :destroy

  enum :status, { draft: 0, sent: 1, approved: 2, rejected: 3 }
end
