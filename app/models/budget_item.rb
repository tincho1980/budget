class BudgetItem < ApplicationRecord
  include SeniorityLevel

  belongs_to :budget
  belongs_to :rate
  has_many :time_entries, dependent: :restrict_with_error

  validates :description, presence: true
  validates :level, presence: true
  validates :estimated_hours, numericality: { greater_than: 0 }
  validate :budget_must_be_draft

  # Rule 2: the rate is frozen when the item is created.
  before_validation :assign_current_rate, if: -> { level.present? && (rate.nil? || (persisted? && will_save_change_to_level?)) }
  before_destroy :ensure_budget_is_draft, unless: :destroyed_by_association
  after_save :refresh_budget_total
  after_destroy :refresh_budget_total, unless: :destroyed_by_association

  def subtotal
    estimated_hours * rate.hourly_value
  end

  def logged_hours
    time_entries.sum(:hours)
  end

  # Rule 7: positive means more hours than estimated.
  def deviation
    logged_hours - estimated_hours
  end

  private

  def assign_current_rate
    self.rate = Rate.current_for(level)
  end

  # Rule 4: approved or sent budgets are immutable; a new version is needed.
  def budget_must_be_draft
    return if budget.nil? || budget.draft?

    errors.add(:base, "El presupuesto ya no es un borrador: creá una nueva versión para modificarlo.")
  end

  def ensure_budget_is_draft
    budget_must_be_draft
    throw :abort if errors.any?
  end

  def refresh_budget_total
    budget.calculate_total!
  end
end
