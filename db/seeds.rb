# Demo data for development.
#
#   bin/rails db:seed            loads it into an empty database
#   bin/rails db:seed:replant    empties every table and loads it again
#
# Dates are relative to today so the collection scenarios (up to date, partial
# payment, overdue) still hold whenever the seeds are run.
#
# Budget totals and charge statuses are set here by hand. Once calculate_total!
# and payment application are implemented, the seeds should use them instead.

Faker::Config.locale = "es-AR"
Faker::Config.random = Random.new(42)

TODAY = Date.current
PASSWORD = "password".freeze

def rate_for(level, date)
  Rate.where(level: level).where(valid_from: ..date).order(valid_from: :desc).first!
end

def build_budget(project, version:, status:, created_on:, items:, buffer: 15)
  budget = project.budgets.create!(
    version: version,
    status: status,
    buffer_percentage: buffer,
    created_at: created_on,
    sent_at: (created_on + 2.days unless status == :draft),
    approved_at: (created_on + 7.days if status == :approved)
  )

  items.each_with_index do |(module_name, description, hours, level, billable), position|
    budget.budget_items.create!(
      module_name: module_name,
      description: description,
      estimated_hours: hours,
      level: level,
      billable: billable,
      position: position,
      rate: rate_for(level, created_on)
    )
  end

  billable_cost = budget.budget_items.select(&:billable).sum { |item| item.estimated_hours * item.rate.hourly_value }
  budget.update!(total: (billable_cost * (1 + budget.buffer_percentage / 100)).round(2))
  budget
end

# Creates 12 monthly charges ending in the current month.
# unpaid_months: how many of the most recent due charges are left unpaid.
# partial_last:  the most recent due charge is paid by half.
def build_charges(contract, registered_by:, unpaid_months: 0, partial_last: false, late_days: 0)
  months = 11.downto(0).map { |i| TODAY.beginning_of_month << i }
  due_months = months.select { |month| month.change(day: contract.due_day) <= TODAY }

  months.each do |month|
    due_on = month.change(day: contract.due_day)
    charge = contract.maintenance_charges.create!(period: month.strftime("%Y-%m"), amount: contract.monthly_amount, due_on: due_on)

    if due_on > TODAY
      next # not due yet: stays pending
    end

    recent_index = due_months.size - 1 - due_months.index(month)

    if recent_index < unpaid_months
      charge.overdue!
      next
    end

    partial = partial_last && recent_index.zero?
    applied = partial ? (charge.amount / 2).round(2) : charge.amount

    payment = contract.client.payments.create!(
      registered_by: registered_by,
      paid_on: [ due_on + late_days.days, TODAY ].min,
      amount: applied,
      payment_method: Faker::Base.sample(%i[transfer transfer cash]),
      status: :confirmed
    )
    payment.payment_applications.create!(maintenance_charge: charge, applied_amount: applied)
    charge.update!(status: partial ? :partial : :paid)
  end
end

ActiveRecord::Base.transaction do
  # --- Team ------------------------------------------------------------------

  admin = User.find_or_create_by!(email_address: "admin@adavra.com") do |user|
    user.name = "Martín Admin"
    user.password = PASSWORD
    user.role = :admin
    user.level = :senior
  end

  if Client.exists?
    puts "Ya hay datos cargados. Para regenerarlos: bin/rails db:seed:replant"
    next
  end

  senior_dev = User.create!(name: "Marcos Senior", email_address: "marcos@adavra.com",
    password: PASSWORD, role: :developer, level: :senior)
  junior_dev = User.create!(name: "Lucía Junior", email_address: "lucia@adavra.com",
    password: PASSWORD, role: :developer, level: :junior)

  # --- Rates -----------------------------------------------------------------
  # Two validity periods, so older budgets keep the previous hourly value.

  previous_rates_from = (TODAY << 12).beginning_of_month
  current_rates_from = (TODAY << 3).beginning_of_month

  { junior: [ 15_000, 20_000 ], semi: [ 22_000, 28_000 ], senior: [ 30_000, 38_000 ] }.each do |level, (previous, current)|
    Rate.create!(level: level, hourly_value: previous, valid_from: previous_rates_from)
    Rate.create!(level: level, hourly_value: current, valid_from: current_rates_from)
  end

  # --- Clients and portal users ----------------------------------------------

  clients = {
    up_to_date: [ "Panadería La Espiga SRL", "30-71234567-1" ],
    partial:    [ "Estudio Contable Ríos y Asociados", "30-71234567-2" ],
    overdue:    [ "Ferretería El Tornillo SA", "30-71234567-3" ],
    no_contract: [ "Club Social Berisso", "30-71234567-4" ]
  }.transform_values do |business_name, tax_id|
    slug = business_name.parameterize.split("-").first(2).join
    client = Client.create!(
      business_name: business_name,
      tax_id: tax_id,
      contact_name: Faker::Name.name,
      email: "contacto@#{slug}.com.ar",
      phone: Faker::PhoneNumber.phone_number
    )
    client.users.create!(name: client.contact_name, email_address: "portal@#{slug}.com.ar",
      password: PASSWORD, role: :client)
    client
  end

  # --- Projects, budgets and hours -------------------------------------------

  # [module, description, estimated hours, level, billable]
  survey_items = [
    [ "Relevamiento", "Entrevistas con la comisión directiva", 6, :senior, true ],
    [ "Web", "Sitio institucional con agenda de actividades", 40, :semi, true ],
    [ "Web", "Formulario de inscripción de socios", 16, :junior, true ]
  ]

  in_progress_items = [
    [ "Autenticación", "Login y recuperación de contraseña", 12, :semi, true ],
    [ "Clientes", "ABM de clientes con búsqueda", 20, :junior, true ],
    [ "Liquidaciones", "Cálculo de honorarios mensuales", 32, :senior, true ],
    [ "Reportes", "Exportación a Excel", 10, :junior, true ],
    [ "Interno", "Configuración de CI y deploy", 6, :senior, false ]
  ]

  delivered_items = [
    [ "Catálogo", "Listado de productos con precios", 24, :semi, true ],
    [ "Pedidos", "Pedido online con retiro en local", 30, :senior, true ],
    [ "Interno", "Capacitación al personal", 4, :junior, false ]
  ]

  survey_project = clients[:no_contract].projects.create!(name: "Sitio del club",
    description: "Sitio institucional e inscripción online de socios", status: :survey, started_on: TODAY - 10)
  build_budget(survey_project, version: 1, status: :draft, created_on: TODAY - 5, items: survey_items)

  in_progress_project = clients[:partial].projects.create!(name: "Sistema de liquidaciones",
    description: "Gestión de clientes y liquidación de honorarios", status: :in_progress, started_on: TODAY << 2)
  build_budget(in_progress_project, version: 1, status: :rejected, created_on: (TODAY << 3) - 10,
    items: in_progress_items.first(4), buffer: 25)
  approved = build_budget(in_progress_project, version: 2, status: :approved, created_on: TODAY << 2,
    items: in_progress_items)

  # Logged hours: some items over estimate, others under, one not started yet.
  work_notes = [ "Desarrollo", "Ajustes tras revisión", "Pruebas y correcciones", "Reunión con el cliente" ]
  { 0 => [ senior_dev, 15 ], 1 => [ junior_dev, 14 ], 2 => [ senior_dev, 36 ], 4 => [ senior_dev, 5 ] }.each do |index, (user, total_hours)|
    item = approved.budget_items.order(:position)[index]
    full_days, remainder = total_hours.divmod(4)
    entries = Array.new(full_days, 4)
    entries << remainder if remainder.positive?
    entries.each_with_index do |hours, day|
      item.time_entries.create!(user: user, worked_on: TODAY - (entries.size - day) * 2, hours: hours,
        description: Faker::Base.sample(work_notes))
    end
  end

  delivered_project = clients[:up_to_date].projects.create!(name: "Tienda online",
    description: "Catálogo y pedidos con retiro en el local", status: :delivered,
    started_on: TODAY << 13, closed_on: nil)
  build_budget(delivered_project, version: 1, status: :approved, created_on: TODAY << 12, items: delivered_items)

  # --- Maintenance contracts, charges and payments ---------------------------

  contract_start = (TODAY << 11).beginning_of_month

  build_charges(
    clients[:up_to_date].maintenance_contracts.create!(project: delivered_project, monthly_amount: 150_000,
      due_day: 10, starts_on: contract_start),
    registered_by: admin
  )

  build_charges(
    clients[:partial].maintenance_contracts.create!(monthly_amount: 90_000, due_day: 5, starts_on: contract_start),
    registered_by: admin, partial_last: true, late_days: 12
  )

  overdue_contract = clients[:overdue].maintenance_contracts.create!(monthly_amount: 120_000, due_day: 15,
    starts_on: contract_start)
  build_charges(overdue_contract, registered_by: admin, unpaid_months: 4)

  # A transfer reported from the client portal, waiting for an admin to review it.
  overdue_client = clients[:overdue]
  overdue_client.payments.create!(registered_by: overdue_client.users.first, paid_on: TODAY - 1,
    amount: 120_000, payment_method: :transfer, status: :pending_review, notes: "Transferencia informada desde el portal")

  # --- Summary ---------------------------------------------------------------

  puts "Seeds cargados:"
  [ User, Rate, Client, Project, Budget, BudgetItem, TimeEntry,
    MaintenanceContract, MaintenanceCharge, Payment, PaymentApplication ].each do |model|
    puts "  #{model.name.ljust(20)} #{model.count}"
  end
  puts "Cuotas vencidas: #{MaintenanceCharge.overdue.count} · parciales: #{MaintenanceCharge.partial.count}"
  puts "Acceso: admin@adavra.com / #{PASSWORD}"
end
