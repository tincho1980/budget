class TimeEntry < ApplicationRecord
  belongs_to :budget_item
  belongs_to :user

  validates :worked_on, presence: true
  validates :hours, numericality: { greater_than: 0, less_than_or_equal_to: 24 }
  validate :project_must_be_open

  private

  # Rule 8.
  def project_must_be_open
    return unless budget_item&.budget&.project&.closed?

    errors.add(:base, "No se pueden cargar horas en un proyecto cerrado.")
  end
end
