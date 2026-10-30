# Run the collection jobs by hand, for example during a demo:
#   bin/rails cobranza:todo
namespace :cobranza do
  desc "Genera la cuota del mes de cada contrato activo"
  task generar_cuotas: :environment do
    before = MaintenanceCharge.count
    GenerateMonthlyChargesJob.perform_now
    puts "Cuotas generadas: #{MaintenanceCharge.count - before}"
  end

  desc "Marca como vencidas las cuotas pendientes pasadas de fecha y avisa al cliente"
  task marcar_vencidas: :environment do
    before = MaintenanceCharge.overdue.count
    MarkOverdueChargesJob.perform_now
    puts "Cuotas que pasaron a vencidas: #{MaintenanceCharge.overdue.count - before}"
  end

  desc "Envía el recordatorio de las cuotas próximas a vencer"
  task recordatorios: :environment do
    due_on = Date.current + SendDueRemindersJob::DAYS_BEFORE
    count = MaintenanceCharge.where(status: %i[ pending partial ], due_on: due_on).count
    SendDueRemindersJob.perform_now
    puts "Recordatorios encolados: #{count} (cuotas que vencen el #{I18n.l(due_on)})"
  end

  desc "Corre las tres tareas de cobranza en orden"
  task todo: %i[ generar_cuotas marcar_vencidas recordatorios ]
end
