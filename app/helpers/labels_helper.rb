# Spanish labels for enum values, shared by every back-office screen.
module LabelsHelper
  ENUM_LABELS = {
    # Budget
    "draft" => "Borrador", "sent" => "Enviado", "approved" => "Aprobado", "rejected" => "Rechazado",
    # MaintenanceCharge
    "pending" => "Pendiente", "partial" => "Parcial", "paid" => "Pagada", "overdue" => "Vencida",
    # Project
    "survey" => "Relevamiento", "in_progress" => "En curso", "delivered" => "Entregado", "closed" => "Cerrado",
    # MaintenanceContract
    "active" => "Activo", "paused" => "Pausado", "cancelled" => "Cancelado",
    # Payment
    "pending_review" => "En revisión", "confirmed" => "Confirmado",
    "transfer" => "Transferencia", "cash" => "Efectivo", "check" => "Cheque",
    # User
    "client" => "Cliente", "developer" => "Developer", "admin" => "Admin",
    "junior" => "Junior", "semi" => "Semi senior", "senior" => "Senior"
  }.freeze

  def status_label(value)
    ENUM_LABELS.fetch(value.to_s, value.to_s.humanize)
  end

  # Options for a <select> built from an enum: [["Borrador", "draft"], ...]
  def enum_options(model, enum_name)
    model.public_send(enum_name).keys.map { |key| [ status_label(key), key ] }
  end

  def hours(value)
    number_with_precision(value, precision: 2, strip_insignificant_zeros: true)
  end
end
