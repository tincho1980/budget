class MaintenanceContract < ApplicationRecord
  belongs_to :client
  belongs_to :project, optional: true
  has_many :maintenance_charges, dependent: :restrict_with_error

  enum :status, { active: 0, paused: 1, cancelled: 2 }
end
