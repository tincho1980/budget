module Admin::DashboardHelper
  STATUS_LABELS = {
    "draft" => "Borrador", "sent" => "Enviado", "approved" => "Aprobado", "rejected" => "Rechazado",
    "pending" => "Pendiente", "partial" => "Parcial", "paid" => "Pagada", "overdue" => "Vencida"
  }.freeze

  def status_label(status)
    STATUS_LABELS.fetch(status, status)
  end
end
