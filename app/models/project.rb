class Project < ApplicationRecord
  belongs_to :client
  has_many :budgets, dependent: :restrict_with_error
  has_one :maintenance_contract, dependent: :restrict_with_error

  enum :status, { survey: 0, in_progress: 1, delivered: 2, closed: 3 }, validate: true

  validates :name, presence: true

  def next_budget_version
    (budgets.maximum(:version) || 0) + 1
  end

  def approved_budget
    budgets.approved.first
  end
end
