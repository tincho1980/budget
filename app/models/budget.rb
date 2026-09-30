class Budget < ApplicationRecord
  belongs_to :project
  has_many :budget_items, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :budget

  enum :status, { draft: 0, sent: 1, approved: 2, rejected: 3 }, validate: true

  validates :version, numericality: { only_integer: true, greater_than: 0 },
    uniqueness: { scope: :project_id }
  validates :buffer_percentage, numericality: { greater_than_or_equal_to: 0 }
  validates :total, numericality: { greater_than_or_equal_to: 0 }
  validate :single_approved_budget_per_project, if: :approved?

  after_update :calculate_total!, if: :saved_change_to_buffer_percentage?

  # Drafts are internal: clients only see budgets once they are sent.
  scope :visible_to_client, -> { where.not(status: :draft) }

  # Rule 1 and 6: billable hours x frozen rate, plus the buffer.
  def calculate_total!
    billable_cost = BudgetItem.where(budget_id: id, billable: true).joins(:rate)
      .sum("budget_items.estimated_hours * rates.hourly_value")
    update_column(:total, (billable_cost * (1 + buffer_percentage / 100)).round(2))
  end

  # Rule 5: never send an empty budget.
  def send_to_client
    errors.clear
    errors.add(:base, "Sólo se puede enviar un presupuesto en borrador.") unless draft?
    errors.add(:base, "No se puede enviar un presupuesto sin ítems o con total en cero.") if budget_items.empty? || total.zero?
    return false if errors.any?

    update(status: :sent, sent_at: Time.current)
  end

  # Rule 3: draft -> sent -> approved | rejected, never backwards.
  def approve
    return false unless decidable?
    update(status: :approved, approved_at: Time.current)
  end

  def reject
    return false unless decidable?
    update(status: :rejected)
  end

  def logged_hours
    TimeEntry.joins(:budget_item).where(budget_items: { budget_id: id }).sum(:hours)
  end

  def estimated_hours
    budget_items.sum(:estimated_hours)
  end

  private

  def decidable?
    return true if sent?
    errors.add(:base, "Sólo se puede aprobar o rechazar un presupuesto enviado.")
    false
  end

  def single_approved_budget_per_project
    return unless project && project.budgets.approved.where.not(id: id).exists?

    errors.add(:base, "El proyecto ya tiene un presupuesto aprobado.")
  end
end
