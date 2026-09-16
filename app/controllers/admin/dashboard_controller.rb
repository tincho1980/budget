class Admin::DashboardController < Admin::BaseController
  OVERDUE_BUCKETS = {
    "1 a 30 días" => 1..30,
    "31 a 60 días" => 31..60,
    "61 a 90 días" => 61..90,
    "Más de 90 días" => 91..
  }.freeze

  def index
    unpaid = MaintenanceCharge.where(status: %i[pending partial overdue])
      .includes(:payment_applications, maintenance_contract: :client)
    overdue, pending = unpaid.partition(&:overdue?)

    @collected_this_month = Payment.confirmed.where(paid_on: Date.current.all_month).sum(:amount)
    @pending_total = pending.sum(&:balance)
    @overdue_total = overdue.sum(&:balance)

    @overdue_buckets = OVERDUE_BUCKETS.transform_values do |range|
      charges = overdue.select { |charge| range.cover?(charge.days_overdue) }
      { count: charges.size, balance: charges.sum(&:balance) }
    end

    @debtors = unpaid.group_by { |charge| charge.maintenance_contract.client }.map do |client, charges|
      { client: client, charges: charges.size, balance: charges.sum(&:balance),
        max_days_overdue: charges.select(&:overdue?).map(&:days_overdue).max || 0 }
    end.sort_by { |debtor| -debtor[:balance] }

    @payments_in_review = Payment.pending_review.includes(:client, :registered_by).order(paid_on: :desc)
    @recent_payments = Payment.confirmed.includes(:client).order(paid_on: :desc, id: :desc).limit(5)
    @budgets = Budget.includes(project: :client).order(:project_id, :version)
  end
end
