class Budget < ApplicationRecord
  belongs_to :project
  has_many :budget_items, dependent: :destroy

  enum :status, { draft: 0, sent: 1, approved: 2, rejected: 3 }, validate: true

  validates :version, numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :project_id }
  validates :buffer_percentage, numericality: { greater_than_or_equal_to: 0 }
  validates :total, numericality: { greater_than_or_equal_to: 0 }
end
